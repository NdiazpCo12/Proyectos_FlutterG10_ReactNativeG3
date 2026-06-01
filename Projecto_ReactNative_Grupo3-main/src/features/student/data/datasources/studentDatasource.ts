import {
  emptyStudentResultsSummary,
  StudentAssessmentAssignment,
  StudentAssessmentHistoryItem,
  StudentAssessmentTeammate,
  StudentCourseEnrollment,
  StudentCourseResults,
  StudentResultCriterionScore,
  StudentResultsSummary,
} from '../../domain/entities/studentModels';
import type {
  RobleAssessment,
  RobleAssessmentSubmission,
} from '../../../../core/roble/models';
import { average } from '../../../../utils/format';
import { robleClient } from '../../../../core/roble/robleClient';
import {
  mapAssessment,
  mapCourse,
  mapCourseGroup,
  mapCriterion,
  mapCriterionLevel,
  mapGroupCategory,
  mapGroupMember,
  mapPeerReview,
  mapScore,
  mapStudent,
  mapSubmission,
  peerReviewToJson,
  scoreToJson,
  submissionToJson,
} from '../../../../core/roble/mappers';

const isSubmitted = (submission?: RobleAssessmentSubmission) =>
  Boolean(
    submission &&
      (submission.status.trim().toLowerCase() === 'submitted' ||
        submission.submittedAt),
  );

const statusFor = (
  assessment: RobleAssessment,
  submitted: boolean,
  teammatesCount = 1,
  criteriaCount = 1,
) => {
  if (submitted) return 'Completed';
  const now = new Date();
  const normalized = assessment.status.trim().toLowerCase();
  if (normalized === 'closed' || now > assessment.endsAt) return 'Closed';
  if (now < assessment.startsAt) return 'Scheduled';
  if (teammatesCount === 0) return 'No teammates';
  if (criteriaCount === 0) return 'No criteria';
  return 'Active';
};

const canSubmit = (
  assessment: RobleAssessment,
  submitted: boolean,
  teammatesCount: number,
  criteriaCount: number,
) => {
  const now = new Date();
  return (
    !submitted &&
    teammatesCount > 0 &&
    criteriaCount > 0 &&
    assessment.status.trim().toLowerCase() !== 'closed' &&
    now >= assessment.startsAt &&
    now <= assessment.endsAt
  );
};

const publicAssessment = (assessment: RobleAssessment) =>
  assessment.visibility.trim().toLowerCase() === 'public';

const syncExpiredAssessment = async (assessment: RobleAssessment) => {
  const assessmentId = assessment.id?.trim() ?? '';
  if (
    !assessmentId ||
    assessment.status.trim().toLowerCase() === 'closed' ||
    new Date() <= assessment.endsAt
  ) {
    return assessment;
  }
  try {
    await robleClient.update('assessments', '_id', assessmentId, {
      status: 'closed',
    });
    return { ...assessment, status: 'closed' };
  } catch {
    return assessment;
  }
};

const sortResults = <T extends { displayOrder: number; label: string }>(
  values: T[],
) =>
  values.sort((a, b) => {
    const orderCompare = a.displayOrder - b.displayOrder;
    return orderCompare !== 0
      ? orderCompare
      : a.label.toLowerCase().localeCompare(b.label.toLowerCase());
  });

type CriterionAccumulator = {
  label: string;
  displayOrder: number;
  totalScore: number;
  scoreCount: number;
};

type AssessmentAccumulator = {
  assessmentId: string;
  title: string;
  date: Date;
  peerReviewIds: Set<string>;
  criteria: Map<string, CriterionAccumulator>;
  totalScore: number;
  scoreCount: number;
};

type CourseAccumulator = {
  courseId: string;
  courseName: string;
  courseCode: string;
  reviewIds: Set<string>;
  criteria: Map<string, CriterionAccumulator>;
  assessments: Map<string, AssessmentAccumulator>;
  totalScore: number;
  scoreCount: number;
};

const criterionScoresFrom = (map: Map<string, CriterionAccumulator>) =>
  sortResults(
    [...map.values()]
      .filter((item) => item.scoreCount > 0)
      .map<StudentResultCriterionScore>((item) => ({
        label: item.label,
        score: item.totalScore / item.scoreCount,
        responseCount: item.scoreCount,
        displayOrder: item.displayOrder,
      })),
  );

const historyFrom = (map: Map<string, AssessmentAccumulator>) =>
  [...map.values()]
    .filter((item) => item.scoreCount > 0)
    .map<StudentAssessmentHistoryItem>((item) => ({
      assessmentId: item.assessmentId,
      title: item.title,
      date: item.date,
      score: item.totalScore / item.scoreCount,
      reviewCount: item.peerReviewIds.size,
      criteria: criterionScoresFrom(item.criteria),
    }))
    .sort((a, b) => b.date.getTime() - a.date.getTime());

const upsertCriterion = (
  map: Map<string, CriterionAccumulator>,
  label: string,
  displayOrder: number,
  scoreValue: number,
) => {
  const item =
    map.get(label) ??
    ({
      label,
      displayOrder,
      totalScore: 0,
      scoreCount: 0,
    } satisfies CriterionAccumulator);
  item.totalScore += scoreValue;
  item.scoreCount += 1;
  item.displayOrder = Math.min(item.displayOrder, displayOrder);
  map.set(label, item);
};

const studentRowsFor = async (studentEmail: string) => {
  const trimmedEmail = studentEmail.trim().toLowerCase();
  if (!trimmedEmail) return [];
  const rows = await robleClient.read('students', { email: trimmedEmail });
  return rows.map(mapStudent);
};

export const studentService = {
  async getStudentEnrollments(
    studentEmail: string,
  ): Promise<StudentCourseEnrollment[]> {
    const students = await studentRowsFor(studentEmail);
    if (students.length === 0) return [];

    const studentIds = new Set(students.map((student) => student.id));
    const [memberRows, groupRows, categoryRows, courseRows] =
      await Promise.all([
        robleClient.read('group_members'),
        robleClient.read('course_groups'),
        robleClient.read('group_categories'),
        robleClient.read('courses'),
      ]);

    const memberships = memberRows
      .map(mapGroupMember)
      .filter((membership) => studentIds.has(membership.studentId));
    const groupsById = new Map(groupRows.map(mapCourseGroup).map((g) => [g.id, g]));
    const categoriesById = new Map(
      categoryRows.map(mapGroupCategory).map((c) => [c.id, c]),
    );
    const coursesById = new Map(courseRows.map(mapCourse).map((c) => [c.id, c]));
    const seen = new Set<string>();
    const enrollments: StudentCourseEnrollment[] = [];

    memberships.forEach((membership) => {
      const group = groupsById.get(membership.groupId);
      const course = group ? coursesById.get(group.courseId) : undefined;
      if (!group || !course) return;
      const key = `${course.id}:${group.id}:${membership.studentId}`;
      if (seen.has(key)) return;
      seen.add(key);
      enrollments.push({
        course,
        groupName: group.groupName,
        groupCode: group.groupCode,
        groupCategoryName:
          categoriesById.get(group.categoryId)?.name ?? 'Sin categoría',
        enrollmentDate: membership.enrollmentDate,
      });
    });

    return enrollments.sort(
      (a, b) => b.course.createdAt.getTime() - a.course.createdAt.getTime(),
    );
  },

  async getStudentAssessments(
    studentEmail: string,
  ): Promise<StudentAssessmentAssignment[]> {
    const students = await studentRowsFor(studentEmail);
    if (students.length === 0) return [];

    const studentIds = new Set(students.map((student) => student.id));
    const tables = await Promise.all([
      robleClient.read('group_members'),
      robleClient.read('course_groups'),
      robleClient.read('group_categories'),
      robleClient.read('courses'),
      robleClient.read('assessments'),
      robleClient.read('assessment_criteria'),
      robleClient.read('assessment_criterion_levels'),
      robleClient.read('assessment_submissions'),
      robleClient.read('assessment_peer_reviews'),
      robleClient.read('assessment_scores'),
      robleClient.read('students'),
    ]);

    const allMemberships = tables[0].map(mapGroupMember);
    const memberships = allMemberships.filter(
      (membership) =>
        studentIds.has(membership.studentId) && membership.id.trim(),
    );
    if (memberships.length === 0) return [];

    const groupsById = new Map(tables[1].map(mapCourseGroup).map((g) => [g.id, g]));
    const categoriesById = new Map(
      tables[2].map(mapGroupCategory).map((c) => [c.id, c]),
    );
    const coursesById = new Map(tables[3].map(mapCourse).map((c) => [c.id, c]));
    const assessments = await Promise.all(
      tables[4].map(mapAssessment).map(syncExpiredAssessment),
    );

    const assessmentsByCategoryId = new Map<string, RobleAssessment[]>();
    assessments.forEach((assessment) => {
      const list = assessmentsByCategoryId.get(assessment.categoryId) ?? [];
      list.push(assessment);
      assessmentsByCategoryId.set(assessment.categoryId, list);
    });

    const criteriaByAssessmentId = new Map<string, ReturnType<typeof mapCriterion>[]>();
    tables[5].map(mapCriterion).forEach((criterion) => {
      if (!criterion.id) return;
      const list = criteriaByAssessmentId.get(criterion.assessmentId) ?? [];
      list.push(criterion);
      criteriaByAssessmentId.set(criterion.assessmentId, list);
    });
    criteriaByAssessmentId.forEach((list) =>
      list.sort((a, b) => a.displayOrder - b.displayOrder),
    );

    const levelsByCriterionId = new Map<string, ReturnType<typeof mapCriterionLevel>[]>();
    tables[6].map(mapCriterionLevel).forEach((level) => {
      if (!level.criterionId || level.scoreValue <= 0) return;
      const list = levelsByCriterionId.get(level.criterionId) ?? [];
      list.push(level);
      levelsByCriterionId.set(level.criterionId, list);
    });
    levelsByCriterionId.forEach((list) =>
      list.sort((a, b) => a.displayOrder - b.displayOrder),
    );

    const latestSubmission = new Map<string, RobleAssessmentSubmission>();
    const submissionsByKey = new Map<string, RobleAssessmentSubmission[]>();
    tables[7].map(mapSubmission).forEach((submission) => {
      const key = `${submission.assessmentId}:${submission.reviewerStudentId}`;
      const list = submissionsByKey.get(key) ?? [];
      list.push(submission);
      submissionsByKey.set(key, list);
    });
    submissionsByKey.forEach((list, key) => {
      list.sort((a, b) => {
        if (isSubmitted(a) !== isSubmitted(b)) return isSubmitted(a) ? -1 : 1;
        const aDate = a.submittedAt ?? a.startedAt ?? a.createdAt;
        const bDate = b.submittedAt ?? b.startedAt ?? b.createdAt;
        return bDate.getTime() - aDate.getTime();
      });
      latestSubmission.set(key, list[0]);
    });

    const peerReviewsBySubmissionId = new Map<string, ReturnType<typeof mapPeerReview>[]>();
    tables[8].map(mapPeerReview).forEach((review) => {
      if (!review.submissionId) return;
      const list = peerReviewsBySubmissionId.get(review.submissionId) ?? [];
      list.push(review);
      peerReviewsBySubmissionId.set(review.submissionId, list);
    });

    const scoresByPeerReviewId = new Map<string, ReturnType<typeof mapScore>[]>();
    tables[9].map(mapScore).forEach((score) => {
      if (!score.peerReviewId || !score.criterionId) return;
      const list = scoresByPeerReviewId.get(score.peerReviewId) ?? [];
      list.push(score);
      scoresByPeerReviewId.set(score.peerReviewId, list);
    });

    const studentById = new Map(tables[10].map(mapStudent).map((s) => [s.id, s]));
    const membershipsByGroupId = new Map<string, ReturnType<typeof mapGroupMember>[]>();
    allMemberships.forEach((membership) => {
      const list = membershipsByGroupId.get(membership.groupId) ?? [];
      list.push(membership);
      membershipsByGroupId.set(membership.groupId, list);
    });

    const seen = new Set<string>();
    const assignments: StudentAssessmentAssignment[] = [];
    students.forEach((student) => {
      memberships
        .filter((membership) => membership.studentId === student.id)
        .forEach((membership) => {
          const group = groupsById.get(membership.groupId);
          const course = group ? coursesById.get(group.courseId) : undefined;
          if (!group || !course) return;
          const category = categoriesById.get(group.categoryId);
          const categoryAssessments =
            assessmentsByCategoryId.get(group.categoryId) ?? [];

          categoryAssessments.forEach((assessment) => {
            if (assessment.courseId && assessment.courseId !== course.id) return;
            const assignmentKey = `${assessment.id}:${student.id}:${group.id}`;
            if (seen.has(assignmentKey)) return;
            seen.add(assignmentKey);

            const criteria = (criteriaByAssessmentId.get(assessment.id ?? '') ?? [])
              .map((criterion) => ({
                criterion,
                levels: [...(levelsByCriterionId.get(criterion.id ?? '') ?? [])],
              }));

            const teammates = (membershipsByGroupId.get(group.id) ?? [])
              .filter((entry) => entry.studentId && entry.studentId !== student.id)
              .reduce<StudentAssessmentTeammate[]>((list, entry) => {
                if (list.some((item) => item.studentId === entry.studentId)) {
                  return list;
                }
                const teammate = studentById.get(entry.studentId);
                if (!teammate) return list;
                const name = `${teammate.firstName.trim()} ${teammate.lastName.trim()}`.trim();
                list.push({
                  studentId: teammate.id,
                  name: name || teammate.username,
                  email: teammate.email,
                });
                return list;
              }, [])
              .sort((a, b) => a.name.localeCompare(b.name));

            const submission = latestSubmission.get(`${assessment.id ?? ''}:${student.id}`);
            const savedScoresByReviewee: Record<string, Record<string, number>> = {};
            if (submission?.id) {
              (peerReviewsBySubmissionId.get(submission.id) ?? []).forEach((review) => {
                const criterionScores: Record<string, number> = {};
                (scoresByPeerReviewId.get(review.id ?? '') ?? []).forEach((score) => {
                  criterionScores[score.criterionId] = score.scoreValue;
                });
                savedScoresByReviewee[review.revieweeStudentId] = criterionScores;
              });
            }

            const submitted = isSubmitted(submission);
            const statusLabel = statusFor(
              assessment,
              submitted,
              teammates.length,
              criteria.length,
            );
            assignments.push({
              assessment,
              course,
              category,
              group,
              reviewer: student,
              teammates,
              criteria,
              isSubmitted: submitted,
              submissionId: submission?.id,
              submissionStatus: submission?.status,
              submittedAt: submission?.submittedAt,
              savedScoresByReviewee,
              statusLabel,
              categoryName: category?.name ?? 'Sin categoría',
              canSubmit: canSubmit(
                assessment,
                submitted,
                teammates.length,
                criteria.length,
              ),
            });
          });
        });
    });

    const rank = (assignment: StudentAssessmentAssignment) =>
      ({ Active: 0, Scheduled: 1, Completed: 2, Closed: 3 }[
        assignment.statusLabel
      ] ?? 4);

    return assignments.sort((a, b) => {
      const rankCompare = rank(a) - rank(b);
      if (rankCompare !== 0) return rankCompare;
      return a.assessment.endsAt.getTime() - b.assessment.endsAt.getTime();
    });
  },

  async getStudentResults(studentEmail: string): Promise<StudentResultsSummary> {
    const students = await studentRowsFor(studentEmail);
    if (students.length === 0) return emptyStudentResultsSummary;

    const studentIds = new Set(students.map((student) => student.id));
    const [scoreRows, assessmentRows, criterionRows, courseRows] =
      await Promise.all([
        robleClient.read('assessment_scores'),
        robleClient.read('assessments'),
        robleClient.read('assessment_criteria'),
        robleClient.read('courses'),
      ]);

    const scores = scoreRows
      .map(mapScore)
      .filter(
        (score) =>
          studentIds.has(score.revieweeStudentId) && score.scoreValue > 0,
      );
    if (scores.length === 0) return emptyStudentResultsSummary;

    const assessments = await Promise.all(
      assessmentRows.map(mapAssessment).map(syncExpiredAssessment),
    );
    const assessmentById = new Map(
      assessments
        .filter((assessment) => assessment.id)
        .map((assessment) => [assessment.id!, assessment]),
    );
    const criterionById = new Map(
      criterionRows
        .map(mapCriterion)
        .filter((criterion) => criterion.id)
        .map((criterion) => [criterion.id!, criterion]),
    );
    const courseById = new Map(courseRows.map(mapCourse).map((c) => [c.id, c]));

    const criteria = new Map<string, CriterionAccumulator>();
    const assessmentAggregates = new Map<string, AssessmentAccumulator>();
    const courseAggregates = new Map<string, CourseAccumulator>();
    const reviewIds = new Set<string>();
    let totalScore = 0;
    let totalScoreCount = 0;

    scores.forEach((score) => {
      const assessment = assessmentById.get(score.assessmentId.trim());
      if (!assessment || !publicAssessment(assessment)) return;
      const criterion = criterionById.get(score.criterionId.trim());
      if (!criterion) return;

      const assessmentId = assessment.id?.trim() || score.assessmentId.trim();
      const courseId = assessment.courseId.trim();
      if (!assessmentId || !courseId) return;

      const course = courseById.get(courseId);
      const label = criterion.name.trim() || 'Criterion';
      const order = criterion.displayOrder <= 0 ? 999 : criterion.displayOrder;

      totalScore += score.scoreValue;
      totalScoreCount += 1;
      if (score.peerReviewId.trim()) reviewIds.add(score.peerReviewId.trim());
      upsertCriterion(criteria, label, order, score.scoreValue);

      const assessmentAggregate =
        assessmentAggregates.get(assessmentId) ??
        ({
          assessmentId,
          title: assessment.name,
          date: assessment.endsAt,
          peerReviewIds: new Set<string>(),
          criteria: new Map<string, CriterionAccumulator>(),
          totalScore: 0,
          scoreCount: 0,
        } satisfies AssessmentAccumulator);
      assessmentAggregate.totalScore += score.scoreValue;
      assessmentAggregate.scoreCount += 1;
      if (score.peerReviewId.trim()) {
        assessmentAggregate.peerReviewIds.add(score.peerReviewId.trim());
      }
      upsertCriterion(
        assessmentAggregate.criteria,
        label,
        order,
        score.scoreValue,
      );
      assessmentAggregates.set(assessmentId, assessmentAggregate);

      const courseAggregate =
        courseAggregates.get(courseId) ??
        ({
          courseId,
          courseName: course?.name ?? 'Curso',
          courseCode: course?.code ?? '',
          reviewIds: new Set<string>(),
          criteria: new Map<string, CriterionAccumulator>(),
          assessments: new Map<string, AssessmentAccumulator>(),
          totalScore: 0,
          scoreCount: 0,
        } satisfies CourseAccumulator);
      courseAggregate.totalScore += score.scoreValue;
      courseAggregate.scoreCount += 1;
      if (score.peerReviewId.trim()) {
        courseAggregate.reviewIds.add(score.peerReviewId.trim());
      }
      upsertCriterion(courseAggregate.criteria, label, order, score.scoreValue);

      const courseAssessment =
        courseAggregate.assessments.get(assessmentId) ??
        ({
          assessmentId,
          title: assessment.name,
          date: assessment.endsAt,
          peerReviewIds: new Set<string>(),
          criteria: new Map<string, CriterionAccumulator>(),
          totalScore: 0,
          scoreCount: 0,
        } satisfies AssessmentAccumulator);
      courseAssessment.totalScore += score.scoreValue;
      courseAssessment.scoreCount += 1;
      if (score.peerReviewId.trim()) {
        courseAssessment.peerReviewIds.add(score.peerReviewId.trim());
      }
      upsertCriterion(courseAssessment.criteria, label, order, score.scoreValue);
      courseAggregate.assessments.set(assessmentId, courseAssessment);
      courseAggregates.set(courseId, courseAggregate);
    });

    const history = historyFrom(assessmentAggregates);
    const courseResults = [...courseAggregates.values()]
      .filter((item) => item.scoreCount > 0)
      .map<StudentCourseResults>((item) => {
        const label = item.courseCode.trim()
          ? `${item.courseCode} - ${item.courseName}`
          : item.courseName || 'Curso';
        const itemHistory = historyFrom(item.assessments);
        return {
          courseId: item.courseId,
          courseName: item.courseName,
          courseCode: item.courseCode,
          overallScore: item.totalScore / item.scoreCount,
          assessmentCount: itemHistory.length,
          reviewCount: item.reviewIds.size,
          criteria: criterionScoresFrom(item.criteria),
          history: itemHistory,
          displayLabel: label,
          hasResults: item.reviewIds.size > 0 && itemHistory.length > 0,
        };
      })
      .sort((a, b) => a.displayLabel.localeCompare(b.displayLabel));

    return {
      overallScore:
        totalScoreCount === 0 ? 0 : totalScore / Math.max(totalScoreCount, 1),
      assessmentCount: history.length,
      reviewCount: reviewIds.size,
      criteria: criterionScoresFrom(criteria),
      history,
      courseResults,
      hasResults: reviewIds.size > 0 && history.length > 0,
    };
  },

  async submitStudentAssessment(
    assignment: StudentAssessmentAssignment,
    scoresByReviewee: Record<string, Record<string, number>>,
  ) {
    const assessmentId = assignment.assessment.id?.trim() ?? '';
    const reviewerStudentId = assignment.reviewer.id.trim();
    const groupId = assignment.group.id.trim();
    const courseId = assignment.course.id.trim();
    const categoryId = assignment.assessment.categoryId.trim();
    if (!assessmentId || !reviewerStudentId || !groupId || !courseId || !categoryId) {
      throw new Error('No fue posible identificar esta evaluación.');
    }
    if (Object.keys(scoresByReviewee).length === 0) {
      throw new Error('Debes calificar a tus compañeros antes de enviar.');
    }

    const existingRows = await robleClient.read('assessment_submissions', {
      assessment_id: assessmentId,
      reviewer_student_id: reviewerStudentId,
    });
    const existing = existingRows.map(mapSubmission).sort((a, b) => {
      if (isSubmitted(a) !== isSubmitted(b)) return isSubmitted(a) ? -1 : 1;
      const aDate = a.submittedAt ?? a.startedAt ?? a.createdAt;
      const bDate = b.submittedAt ?? b.startedAt ?? b.createdAt;
      return bDate.getTime() - aDate.getTime();
    })[0];
    if (existing && isSubmitted(existing)) {
      throw new Error('Esta evaluación ya fue enviada.');
    }
    if (existing?.id) {
      await this.deleteSubmissionCascade(existing.id);
    }

    const now = new Date();
    let createdSubmissionId: string | undefined;
    try {
      const submissionId = await robleClient.insert(
        'assessment_submissions',
        submissionToJson({
          assessmentId,
          courseId,
          categoryId,
          groupId,
          reviewerStudentId,
          status: 'submitted',
          generalComment: '',
          startedAt: now,
          submittedAt: now,
          createdAt: now,
        }),
      );
      createdSubmissionId = submissionId;

      for (const [revieweeStudentId, criterionScores] of Object.entries(
        scoresByReviewee,
      )) {
        if (
          !revieweeStudentId.trim() ||
          revieweeStudentId === reviewerStudentId ||
          Object.keys(criterionScores).length === 0
        ) {
          continue;
        }

        const peerReviewId = await robleClient.insert(
          'assessment_peer_reviews',
          peerReviewToJson({
            submissionId,
            assessmentId,
            courseId,
            categoryId,
            groupId,
            reviewerStudentId,
            revieweeStudentId,
            generalComment: '',
            createdAt: now,
          }),
        );

        for (const [criterionId, scoreValue] of Object.entries(criterionScores)) {
          if (!criterionId.trim()) continue;
          await robleClient.insert(
            'assessment_scores',
            scoreToJson({
              peerReviewId,
              assessmentId,
              courseId,
              categoryId,
              groupId,
              reviewerStudentId,
              revieweeStudentId,
              criterionId,
              scoreValue,
              createdAt: now,
              updatedAt: now,
            }),
          );
        }
      }
    } catch (error) {
      if (createdSubmissionId) {
        try {
          await this.deleteSubmissionCascade(createdSubmissionId);
        } catch {}
      }
      throw error;
    }
  },

  async deleteSubmissionCascade(submissionId: string) {
    const peerReviewRows = await robleClient.read('assessment_peer_reviews', {
      submission_id: submissionId,
    });
    const peerReviews = peerReviewRows.map(mapPeerReview).filter((r) => r.id);
    for (const review of peerReviews) {
      const scoreRows = await robleClient.read('assessment_scores', {
        peer_review_id: review.id,
      });
      for (const score of scoreRows.map(mapScore).filter((s) => s.id)) {
        await robleClient.deleteById('assessment_scores', score.id!);
      }
      await robleClient.deleteById('assessment_peer_reviews', review.id!);
    }
    await robleClient.deleteById('assessment_submissions', submissionId);
  },
};
