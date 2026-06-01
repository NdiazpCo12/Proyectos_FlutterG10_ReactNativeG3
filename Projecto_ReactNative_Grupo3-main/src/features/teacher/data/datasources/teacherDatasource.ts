import axios from 'axios';

import { robleConfig } from '../../../../config/robleConfig';
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
} from '../../../../core/roble/mappers';
import { authService, defaultUserPassword } from '../../../auth/data/datasources/authDatasource';
import {
  CreateTeacherAssessmentInput,
  TeacherAssessmentCriterionDetail,
  TeacherAssessmentDetail,
  TeacherAssessmentAnalytics,
  TeacherAssessmentOverview,
  TeacherCreateCourseInput,
  TeacherCreateCourseResult,
  TeacherCourseCategory,
  TeacherCourseSummary,
  TeacherCsvImportInput,
  TeacherCsvImportRow,
  TeacherCsvImportResult,
  UpdateTeacherAssessmentInput,
} from '../../domain/entities/teacherModels';

const jsonHeaders = { 'Content-Type': 'application/json; charset=UTF-8' };

const normalizeEmail = (email: string) => email.trim().toLowerCase();
const normalizeCourseName = (name: string) => name.trim().toLowerCase();

const buildCourseCode = (name: string, email: string) => {
  const slug = name
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 12);
  const emailSeed = normalizeEmail(email).split('@')[0]?.toUpperCase().replace(/[^A-Z0-9]/g, '') ?? 'TEACH';
  return `${slug || 'COURSE'}-${emailSeed.slice(0, 4) || 'TEAC'}`;
};

const buildStudentName = (row: TeacherCsvImportRow) => {
  const fullName = `${row.firstName.trim()} ${row.lastName.trim()}`.trim();
  if (fullName) return fullName;
  if (row.username.trim()) return row.username.trim();
  const email = normalizeEmail(row.email);
  return email ? email.split('@')[0] : 'Estudiante';
};

const isExistingAccountError = (error: unknown) => {
  if (!axios.isAxiosError(error)) return false;
  const rawMessage = error.response?.data?.message;
  const message = Array.isArray(rawMessage)
    ? rawMessage.join(' ')
    : String(rawMessage ?? error.message).toLowerCase();
  return (
    error.response?.status === 409 ||
    message.includes('already') ||
    message.includes('exists') ||
    message.includes('duplicate') ||
    message.includes('ya existe') ||
    message.includes('registrado')
  );
};

const formatSpanishDate = (value: string) => {
  const input = value.trim();
  if (!input) return new Date().toISOString();

  const months: Record<string, string> = {
    enero: '01',
    febrero: '02',
    marzo: '03',
    abril: '04',
    mayo: '05',
    junio: '06',
    julio: '07',
    agosto: '08',
    septiembre: '09',
    octubre: '10',
    noviembre: '11',
    diciembre: '12',
  };

  const parsed = Date.parse(input);
  if (!Number.isNaN(parsed)) {
    return new Date(parsed).toISOString();
  }

  const parts = input.toLowerCase().split(' ');
  if (parts.length >= 6) {
    const day = parts[0].padStart(2, '0');
    const month = months[parts[2]] ?? '01';
    const year = parts[4];
    const time = parts[5];
    return `${year}-${month}-${day}T${time}:00.000Z`;
  }

  return new Date().toISOString();
};

const defaultRubric: Array<{
  name: string;
  description: string;
  weight: number;
  displayOrder: number;
  levels: Array<{
    scoreValue: number;
    label: string;
    descriptionEn: string;
    descriptionEs: string;
    displayOrder: number;
  }>;
}> = [
  {
    name: 'Punctuality',
    description: 'Attendance, punctuality and deadline compliance.',
    weight: 25,
    displayOrder: 1,
    levels: [
      {
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Frequently late or absent and affects team progress.',
        descriptionEs: 'Llega tarde o falta con frecuencia y afecta el avance.',
        displayOrder: 1,
      },
      {
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Usually attends but still misses some sessions or times.',
        descriptionEs: 'Asiste normalmente, aunque aun presenta retrasos.',
        displayOrder: 2,
      },
      {
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Generally punctual and reliable in meetings and tasks.',
        descriptionEs: 'Generalmente es puntual y cumple bien con el equipo.',
        displayOrder: 3,
      },
      {
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Consistently punctual, prepared and dependable.',
        descriptionEs: 'Siempre es puntual, preparado y muy confiable.',
        displayOrder: 4,
      },
    ],
  },
  {
    name: 'Contributions',
    description: 'Quality and relevance of delivered work.',
    weight: 25,
    displayOrder: 2,
    levels: [
      {
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Contributes very little and rarely supports outcomes.',
        descriptionEs: 'Aporta muy poco y casi no apoya los entregables.',
        displayOrder: 1,
      },
      {
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Participates occasionally and completes some tasks.',
        descriptionEs: 'Participa de forma ocasional y cumple algunas tareas.',
        displayOrder: 2,
      },
      {
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Makes relevant contributions that support the team.',
        descriptionEs: 'Hace aportes relevantes que apoyan al equipo.',
        displayOrder: 3,
      },
      {
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Provides strong, proactive contributions that improve work.',
        descriptionEs: 'Hace aportes solidos y proactivos que mejoran el trabajo.',
        displayOrder: 4,
      },
    ],
  },
  {
    name: 'Commitment',
    description: 'Responsibility with assigned tasks and team roles.',
    weight: 25,
    displayOrder: 3,
    levels: [
      {
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Shows low commitment and weak ownership of tasks.',
        descriptionEs: 'Muestra poco compromiso y poca apropiacion de tareas.',
        displayOrder: 1,
      },
      {
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Shows acceptable commitment but lacks consistency.',
        descriptionEs: 'Cumple de forma aceptable, pero con poca constancia.',
        displayOrder: 2,
      },
      {
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Demonstrates responsibility and follows through well.',
        descriptionEs: 'Demuestra responsabilidad y cumple bien sus tareas.',
        displayOrder: 3,
      },
      {
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Consistently committed and highly dependable.',
        descriptionEs: 'Es consistentemente comprometido y muy confiable.',
        displayOrder: 4,
      },
    ],
  },
  {
    name: 'Communication',
    description: 'Clarity, respect and effectiveness in team communication.',
    weight: 25,
    displayOrder: 4,
    levels: [
      {
        scoreValue: 2,
        label: 'Needs Improvement',
        descriptionEn: 'Communicates poorly or rarely contributes to coordination.',
        descriptionEs: 'Se comunica poco o dificulta la coordinacion del equipo.',
        displayOrder: 1,
      },
      {
        scoreValue: 3,
        label: 'Adequate',
        descriptionEn: 'Communicates when necessary but could be more proactive.',
        descriptionEs: 'Se comunica cuando hace falta, pero con poca iniciativa.',
        displayOrder: 2,
      },
      {
        scoreValue: 4,
        label: 'Good',
        descriptionEn: 'Communicates clearly and helps coordinate work.',
        descriptionEs: 'Se comunica con claridad y ayuda a coordinar el trabajo.',
        displayOrder: 3,
      },
      {
        scoreValue: 5,
        label: 'Excellent',
        descriptionEn: 'Keeps the team aligned with clear, respectful communication.',
        descriptionEs: 'Mantiene al equipo alineado con comunicacion clara y respetuosa.',
        displayOrder: 4,
      },
    ],
  },
];

const loadAssessmentCriterionDetails = async (
  assessmentId: string,
): Promise<TeacherAssessmentCriterionDetail[]> => {
  const [criterionRows, levelRows] = await Promise.all([
    robleClient.read('assessment_criteria', { assessment_id: assessmentId }),
    robleClient.read('assessment_criterion_levels'),
  ]);

  const levelsByCriterionId = new Map<string, ReturnType<typeof mapCriterionLevel>[]>();
  levelRows.map(mapCriterionLevel).forEach((level) => {
    const list = levelsByCriterionId.get(level.criterionId) ?? [];
    list.push(level);
    levelsByCriterionId.set(level.criterionId, list);
  });

  return criterionRows
    .map(mapCriterion)
    .sort((a, b) => a.displayOrder - b.displayOrder)
    .map((criterion) => ({
      criterion,
      levels: [...(levelsByCriterionId.get(criterion.id ?? '') ?? [])].sort(
        (a, b) => a.displayOrder - b.displayOrder,
      ),
    }));
};

const ensureStudentAccounts = async (rows: TeacherCsvImportRow[]) => {
  const uniqueRows = new Map<string, TeacherCsvImportRow>();
  rows.forEach((row) => {
    const email = normalizeEmail(row.email);
    if (email && !uniqueRows.has(email)) {
      uniqueRows.set(email, row);
    }
  });

  for (const [email, row] of uniqueRows.entries()) {
    try {
      await axios.post(
        `${robleConfig.authBaseUrl}/signup-direct`,
        {
          email,
          password: defaultUserPassword,
          name: buildStudentName(row),
        },
        { headers: jsonHeaders },
      );
    } catch (error) {
      if (!isExistingAccountError(error)) {
        throw error;
      }
    }
  }
};

const resolveStudentIds = async (rows: TeacherCsvImportRow[]) => {
  const seen = new Map<string, string>();

  for (const row of rows) {
    const email = normalizeEmail(row.email);
    if (!email || seen.has(email)) continue;

    const existingRows = await robleClient.read('students', { email });
    if (existingRows.length > 0) {
      const existing = mapStudent(existingRows[0]);
      if (existing.id) {
        seen.set(email, existing.id);
        continue;
      }
    }

    const studentId = await robleClient.insert('students', {
      username: row.username.trim() || email.split('@')[0],
      org_defined_id: row.orgDefinedId.trim() || '00000',
      first_name: row.firstName.trim() || 'Sin nombre',
      last_name: row.lastName.trim() || 'Sin apellido',
      email,
    });
    seen.set(email, studentId);
  }

  return seen;
};

const deleteCategoryData = async (category: ReturnType<typeof mapGroupCategory>) => {
  const groupRows = await robleClient.read('course_groups', {
    category_id: category.id,
  });
  const groups = groupRows.map(mapCourseGroup).filter((group) => group.id.trim());

  const membershipIds = new Set<string>();
  const affectedStudentIds = new Set<string>();

  for (const group of groups) {
    const membershipRows = await robleClient.read('group_members', {
      group_id: group.id,
    });
    membershipRows.map(mapGroupMember).forEach((membership) => {
      if (membership.id.trim()) membershipIds.add(membership.id);
      if (membership.studentId.trim()) {
        affectedStudentIds.add(membership.studentId);
      }
    });
  }

  for (const membershipId of membershipIds) {
    await robleClient.deleteById('group_members', membershipId);
  }

  for (const group of groups) {
    await robleClient.deleteById('course_groups', group.id);
  }

  await robleClient.deleteById('group_categories', category.id);

  for (const studentId of affectedStudentIds) {
    const remainingMemberships = await robleClient.read('group_members', {
      student_id: studentId,
    });
    if (remainingMemberships.length === 0) {
      await robleClient.deleteById('students', studentId);
    }
  }
};

const deleteCourseData = async (courseId: string) => {
  const categoryRows = await robleClient.read('group_categories', {
    course_id: courseId,
  });

  for (const category of categoryRows.map(mapGroupCategory)) {
    if (category.id.trim()) {
      await deleteCategoryData(category);
    }
  }

  await robleClient.deleteById('courses', courseId);
};

const findExistingCourse = async (
  email: string,
  name: string,
  code?: string,
): Promise<TeacherCreateCourseResult | null> => {
  const normalizedEmail = normalizeEmail(email);
  const normalizedName = normalizeCourseName(name);
  const trimmedCode = code?.trim().toUpperCase() ?? '';

  const teacherCourseRows = await robleClient.read('courses', {
    teacher_email: normalizedEmail,
  });
  const teacherCourses = teacherCourseRows.map(mapCourse);

  const byName = teacherCourses.find(
    (course) => normalizeCourseName(course.name) === normalizedName,
  );
  if (byName) {
    return {
      id: byName.id,
      name: byName.name,
      code: byName.code,
      created: false,
    };
  }

  if (trimmedCode) {
    const codeRows = await robleClient.read('courses', { code: trimmedCode });
    const byCode = codeRows
      .map(mapCourse)
      .find((course) => normalizeEmail(course.teacherEmail) === normalizedEmail);
    if (byCode) {
      return {
        id: byCode.id,
        name: byCode.name,
        code: byCode.code,
        created: false,
      };
    }
  }

  return null;
};

const prepareCategoryForUpload = async (courseId: string, categoryName: string) => {
  const existingRows = await robleClient.read('group_categories', {
    course_id: courseId,
    name: categoryName,
  });

  const existingCategories = existingRows
    .map(mapGroupCategory)
    .filter((category) => category.id.trim());

  let replacedExistingData = false;
  for (const category of existingCategories) {
    replacedExistingData = true;
    await deleteCategoryData(category);
  }

  const categoryId = await robleClient.insert('group_categories', {
    course_id: courseId,
    name: categoryName,
  });

  return { categoryId, replacedExistingData };
};

const insertUniqueGroups = async (
  rows: TeacherCsvImportRow[],
  courseId: string,
  categoryId: string,
) => {
  const seen = new Map<string, string>();

  for (const [index, row] of rows.entries()) {
    const groupCode = row.groupCode.trim() || row.groupName.trim() || `GRUPO-${index + 1}`;
    if (seen.has(groupCode)) continue;

    const groupId = await robleClient.insert('course_groups', {
      group_name: row.groupName.trim() || `Grupo ${index + 1}`,
      group_code: groupCode,
      category_id: categoryId,
      course_id: courseId,
    });
    seen.set(groupCode, groupId);
  }

  return seen;
};

const insertGroupMembers = async (
  rows: TeacherCsvImportRow[],
  studentIds: Map<string, string>,
  groupIds: Map<string, string>,
) => {
  const inserted = new Set<string>();

  for (const [index, row] of rows.entries()) {
    const email = normalizeEmail(row.email);
    const groupCode = row.groupCode.trim() || row.groupName.trim() || `GRUPO-${index + 1}`;
    const studentId = studentIds.get(email);
    const groupId = groupIds.get(groupCode);
    if (!studentId || !groupId) continue;

    const key = `${studentId}:${groupId}`;
    if (inserted.has(key)) continue;
    inserted.add(key);

    await robleClient.insert('group_members', {
      student_id: studentId,
      group_id: groupId,
      enrollment_date: formatSpanishDate(row.enrollmentDate),
    });
  }
};

export const teacherService = {
  async getTeacherCourses(
    email: string,
  ): Promise<TeacherCourseSummary[]> {
    const trimmed = email.trim().toLowerCase();
    if (!trimmed) return [];

    const courseRows = await robleClient.read('courses', {
      teacher_email: trimmed,
    });
    const courses = courseRows.map(mapCourse);

    // Enrich with student count from group members
    const result: TeacherCourseSummary[] = [];
    for (const course of courses) {
      let studentCount = 0;
      try {
        const groupRows = await robleClient.read('course_groups', {
          course_id: course.id,
        });
        const groups = groupRows.map(mapCourseGroup);
        for (const group of groups) {
          const memberRows = await robleClient.read('group_members', {
            group_id: group.id,
          });
          studentCount += memberRows.length;
        }
      } catch {
        // best-effort enrichment
      }
      result.push({
        ...course,
        studentCount,
      });
    }

    return result.sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime(),
    );
  },

  async createOrResolveCourse(
    input: TeacherCreateCourseInput,
  ): Promise<TeacherCreateCourseResult> {
    const normalizedEmail = normalizeEmail(input.email);
    const trimmedName = input.name.trim();
    const trimmedCode = input.code?.trim().toUpperCase() ?? '';

    if (!normalizedEmail) {
      throw new Error('El docente autenticado no tiene un correo válido.');
    }
    if (!trimmedName) {
      throw new Error('El nombre del curso es obligatorio.');
    }

    const existing = await findExistingCourse(normalizedEmail, trimmedName, trimmedCode);
    if (existing) {
      return existing;
    }

    const code = trimmedCode || buildCourseCode(trimmedName, normalizedEmail);
    const id = await robleClient.insert('courses', {
      name: trimmedName,
      code,
      teacher_email: normalizedEmail,
      status: 'Active',
      created_at: new Date().toISOString(),
    });

    return {
      id,
      name: trimmedName,
      code,
      created: true,
    };
  },

  async getTeacherAssessments(
    email: string,
  ): Promise<TeacherAssessmentOverview[]> {
    const trimmed = email.trim().toLowerCase();
    if (!trimmed) return [];

    const [courseRows, assessmentRows] = await Promise.all([
      robleClient.read('courses', { teacher_email: trimmed }),
      robleClient.read('assessments', { created_by_email: trimmed }),
    ]);

    const coursesById = new Map(
      courseRows.map(mapCourse).map((c) => [c.id, c]),
    );
    const assessments = assessmentRows.map(mapAssessment);

    const result: TeacherAssessmentOverview[] = [];
    for (const assessment of assessments) {
      const course = coursesById.get(assessment.courseId);
      let submissionCount = 0;
      let groupCount = 0;
      try {
        const submissions = await robleClient.read(
          'assessment_submissions',
          { assessment_id: assessment.id ?? '' },
        );
        submissionCount = submissions.length;

        const groupIds = new Set<string>();
        const groupRows = await robleClient.read('course_groups', {
          course_id: assessment.courseId,
        });
        groupRows.map(mapCourseGroup).forEach((g) => {
          if (g.categoryId === assessment.categoryId) {
            groupIds.add(g.id);
          }
        });
        groupCount = groupIds.size;
      } catch {
        // best-effort
      }

      result.push({
        assessment,
        courseName: course?.name ?? 'Curso',
        courseCode: course?.code ?? '',
        submissionCount,
        groupCount,
      });
    }

    return result.sort(
      (a, b) => b.assessment.createdAt.getTime() - a.assessment.createdAt.getTime(),
    );
  },

  async getCourseCategories(courseId: string): Promise<TeacherCourseCategory[]> {
    const trimmed = courseId.trim();
    if (!trimmed) return [];

    const [categoryRows, groupRows] = await Promise.all([
      robleClient.read('group_categories', { course_id: trimmed }),
      robleClient.read('course_groups', { course_id: trimmed }),
    ]);

    const groups = groupRows.map(mapCourseGroup);
    return categoryRows
      .map(mapGroupCategory)
      .map((category) => ({
        id: category.id,
        name: category.name,
        groupCount: groups.filter((group) => group.categoryId === category.id).length,
      }))
      .sort((a, b) => a.name.localeCompare(b.name));
  },

  async getAssessmentDetail(
    assessmentId: string,
  ): Promise<TeacherAssessmentDetail | null> {
    const trimmed = assessmentId.trim();
    if (!trimmed) return null;

    const assessmentRows = await robleClient.read('assessments', { _id: trimmed });
    if (assessmentRows.length === 0) return null;

    const assessment = mapAssessment(assessmentRows[0]);
    const [courseRows, categoryRows, submissionRows, criteria] = await Promise.all([
      robleClient.read('courses', { _id: assessment.courseId }),
      robleClient.read('group_categories', { _id: assessment.categoryId }),
      robleClient.read('assessment_submissions', { assessment_id: trimmed }),
      loadAssessmentCriterionDetails(trimmed),
    ]);

    const course = courseRows.length > 0 ? mapCourse(courseRows[0]) : null;
    const category = categoryRows.length > 0 ? mapGroupCategory(categoryRows[0]) : null;
    const submissions = submissionRows.map(mapSubmission);
    const submittedCount = submissions.filter((submission) => {
      const status = submission.status.trim().toLowerCase();
      return status === 'submitted' || Boolean(submission.submittedAt);
    }).length;
    const reviewerIds = new Set(
      submissions
        .map((submission) => submission.reviewerStudentId.trim())
        .filter(Boolean),
    );

    return {
      assessment,
      courseName: course?.name ?? 'Curso',
      courseCode: course?.code ?? '',
      categoryName: category?.name ?? 'Sin categoría',
      totalReviewers: reviewerIds.size,
      responsesSubmitted: submittedCount,
      criteria,
    };
  },

  async getAssessmentAnalytics(
    assessmentId: string,
  ): Promise<TeacherAssessmentAnalytics | null> {
    const trimmed = assessmentId.trim();
    if (!trimmed) return null;

    const assessmentRows = await robleClient.read('assessments', {
      _id: trimmed,
    });
    if (assessmentRows.length === 0) return null;

    const assessment = mapAssessment(assessmentRows[0]);
    const courseRows = await robleClient.read('courses', {
      _id: assessment.courseId,
    });
    const course = courseRows.length > 0 ? mapCourse(courseRows[0]) : null;

    // Gather groups for this course+category
    const groupRows = await robleClient.read('course_groups', {
      course_id: assessment.courseId,
    });
    const groups = groupRows
      .map(mapCourseGroup)
      .filter((g) => g.categoryId === assessment.categoryId);

    // Collect scores for this assessment via submissions → peer reviews → scores
    const [submissionRows, studentRows] = await Promise.all([
      robleClient.read('assessment_submissions', { assessment_id: trimmed }),
      robleClient.read('students'),
    ]);
    const studentsById = new Map(
      studentRows.map(mapStudent).map((student) => [student.id, student]),
    );

    const groupBreakdown: TeacherAssessmentAnalytics['groupBreakdown'] = [];

    for (const group of groups) {
      const groupSubmissions = submissionRows.filter(
        (s) => s.group_id === group.id,
      );
      const completedSubmissions = groupSubmissions.filter(
        (s) =>
          typeof s.status === 'string' &&
          s.status.toLowerCase() === 'submitted',
      );

      // Count distinct students in this group
      const memberRows = await robleClient.read('group_members', {
        group_id: group.id,
      });

      let totalScore = 0;
      let scoreCount = 0;
      const studentScores = new Map<
        string,
        { totalScore: number; scoreCount: number }
      >();
      for (const sub of completedSubmissions) {
        const reviewRows = await robleClient.read(
          'assessment_peer_reviews',
          { submission_id: sub._id ?? sub.id },
        );
        for (const review of reviewRows) {
          const scoreRows = await robleClient.read('assessment_scores', {
            peer_review_id: review._id ?? review.id,
          });
          for (const score of scoreRows) {
            const val = Number(score.score_value);
            if (Number.isFinite(val) && val > 0) {
              totalScore += val;
              scoreCount += 1;
              const revieweeId = String(score.reviewee_student_id ?? '').trim();
              if (revieweeId) {
                const current = studentScores.get(revieweeId) ?? {
                  totalScore: 0,
                  scoreCount: 0,
                };
                current.totalScore += val;
                current.scoreCount += 1;
                studentScores.set(revieweeId, current);
              }
            }
          }
        }
      }

      const uniqueMemberIds = new Set<string>();
      const students = memberRows
        .map((row) => String(row.student_id ?? '').trim())
        .filter((studentId) => {
          if (!studentId || uniqueMemberIds.has(studentId)) return false;
          uniqueMemberIds.add(studentId);
          return true;
        })
        .map((studentId) => {
          const scoreEntry = studentScores.get(studentId);
          const student = studentsById.get(studentId);
          const fullName = `${student?.firstName ?? ''} ${student?.lastName ?? ''}`.trim();
          return {
            studentId,
            name: fullName || student?.username || 'Estudiante',
            email: student?.email ?? '',
            averageScore:
              scoreEntry && scoreEntry.scoreCount > 0
                ? scoreEntry.totalScore / scoreEntry.scoreCount
                : 0,
          };
        })
        .sort((a, b) => a.name.localeCompare(b.name));

      groupBreakdown.push({
        groupId: group.id,
        groupName: group.groupName,
        studentCount: memberRows.length,
        submissionCount: groupSubmissions.length,
        completedCount: completedSubmissions.length,
        averageScore: scoreCount > 0 ? totalScore / scoreCount : 0,
        students,
      });
    }

    const totalStudents = groupBreakdown.reduce(
      (sum, g) => sum + g.studentCount,
      0,
    );
    const totalSubmissions = groupBreakdown.reduce(
      (sum, g) => sum + g.submissionCount,
      0,
    );
    const completedSubmissions = groupBreakdown.reduce(
      (sum, g) => sum + g.completedCount,
      0,
    );

    return {
      assessmentId: trimmed,
      assessmentName: assessment.name,
      courseId: assessment.courseId,
      courseName: course?.name ?? 'Curso',
      courseCode: course?.code ?? '',
      totalGroups: groups.length,
      totalStudents,
      totalSubmissions,
      completedSubmissions,
      groupBreakdown,
    };
  },

  async createAssessment(
    input: CreateTeacherAssessmentInput,
  ): Promise<string> {
    const user = await authService.getStoredUser();
    const now = new Date();
    const id = await robleClient.insert('assessments', {
      course_id: input.courseId,
      category_id: input.categoryId,
      name: input.name,
      visibility: input.visibility ?? 'private',
      status: 'open',
      starts_at: input.startsAt.toISOString(),
      ends_at: input.endsAt.toISOString(),
      created_by_email: user?.email ?? '',
      created_at: now.toISOString(),
    });

    for (const criterionTemplate of defaultRubric) {
      const criterionId = await robleClient.insert('assessment_criteria', {
        assessment_id: id,
        name: criterionTemplate.name,
        description: criterionTemplate.description,
        weight: criterionTemplate.weight,
        display_order: criterionTemplate.displayOrder,
        created_at: now.toISOString(),
      });

      for (const levelTemplate of criterionTemplate.levels) {
        await robleClient.insert('assessment_criterion_levels', {
          criterion_id: criterionId,
          score_value: levelTemplate.scoreValue,
          label: levelTemplate.label,
          description_en: levelTemplate.descriptionEn,
          description_es: levelTemplate.descriptionEs,
          display_order: levelTemplate.displayOrder,
        });
      }
    }

    return id;
  },

  async updateAssessment(input: UpdateTeacherAssessmentInput): Promise<void> {
    const trimmed = input.assessmentId.trim();
    if (!trimmed) return;

    await robleClient.update('assessments', '_id', trimmed, {
      name: input.name,
      visibility: input.visibility ?? 'private',
      status: input.status ?? 'open',
      starts_at: input.startsAt.toISOString(),
      ends_at: input.endsAt.toISOString(),
    });
  },

  async importCourseCsv(
    input: TeacherCsvImportInput,
  ): Promise<TeacherCsvImportResult> {
    if (!input.rows || input.rows.length === 0) {
      return {
        success: false,
        studentCount: 0,
        groupCount: 0,
        errors: ['No hay filas para importar.'],
      };
    }
    if (
      !input.courseCode.trim() &&
      !input.courseId?.trim() &&
      !input.courseName?.trim()
    ) {
      return {
        success: false,
        studentCount: 0,
        groupCount: 0,
        errors: ['Debes indicar un curso válido para importar el CSV.'],
      };
    }

    const normalizedRows = input.rows.map((row) => ({
      ...row,
      email: normalizeEmail(row.email),
    }));
    const categoryNames = new Set(
      normalizedRows
        .map((row) => row.groupCategoryName.trim())
        .filter(Boolean),
    );

    if (categoryNames.size > 1) {
      return {
        success: false,
        studentCount: 0,
        groupCount: 0,
        errors: ['El CSV debe contener una sola categoría por importación.'],
      };
    }

    const invalidRows = normalizedRows.filter(
      (row) => !row.email || (!row.groupName.trim() && !row.groupCode.trim()),
    );
    if (invalidRows.length > 0) {
      return {
        success: false,
        studentCount: 0,
        groupCount: 0,
        errors: [
          'Hay filas sin correo o sin información de grupo. Corrige el archivo antes de confirmar.',
        ],
      };
    }

    let courseId = input.courseId?.trim() ?? '';
    let createdCourse = false;

    try {
      if (!courseId && input.teacherEmail?.trim() && input.courseName?.trim()) {
        const resolved = await this.createOrResolveCourse({
          email: input.teacherEmail,
          name: input.courseName,
          code: input.courseCode,
        });
        courseId = resolved.id;
        createdCourse = resolved.created;
      }

      if (!courseId) {
        const courseRows = await robleClient.read('courses', {
          code: input.courseCode.trim(),
        });
        const course = courseRows.map(mapCourse).find((item) => item.id.trim());
        if (!course) {
          return {
            success: false,
            studentCount: 0,
            groupCount: 0,
            errors: ['No encontramos el curso seleccionado en Roble.'],
          };
        }
        courseId = course.id;
      }

      const categoryName =
        input.groupCategoryName.trim() || [...categoryNames][0] || 'Categoria General';

      await ensureStudentAccounts(normalizedRows);
      const { categoryId } = await prepareCategoryForUpload(courseId, categoryName);
      const groupIds = await insertUniqueGroups(normalizedRows, courseId, categoryId);
      const studentIds = await resolveStudentIds(normalizedRows);
      await insertGroupMembers(normalizedRows, studentIds, groupIds);

      return {
        success: true,
        courseId,
        studentCount: studentIds.size,
        groupCount: groupIds.size,
        errors: [],
      };
    } catch (error) {
      if (createdCourse && courseId) {
        try {
          await deleteCourseData(courseId);
        } catch {
          // best-effort cleanup for newly created course
        }
      }
      throw error;
    }
  },

  async deleteAssessment(assessmentId: string): Promise<void> {
    const trimmed = assessmentId.trim();
    if (!trimmed) return;

    const submissionRows = await robleClient.read('assessment_submissions', {
      assessment_id: trimmed,
    });
    const submissions = submissionRows.map(mapSubmission).filter((item) => item.id?.trim());

    const reviewRows = await robleClient.read('assessment_peer_reviews', {
      assessment_id: trimmed,
    });
    const reviews = reviewRows.map(mapPeerReview).filter((item) => item.id?.trim());

    const reviewIds = new Set<string>();

    for (const submission of submissions) {
      const relatedReviews = await robleClient.read('assessment_peer_reviews', {
        submission_id: submission.id ?? '',
      });
      relatedReviews.map(mapPeerReview).forEach((review) => {
        if (review.id) reviewIds.add(review.id);
      });
    }

    reviews.forEach((review) => {
      if (review.id) reviewIds.add(review.id);
    });

    for (const reviewId of reviewIds) {
      const scoreRows = await robleClient.read('assessment_scores', {
        peer_review_id: reviewId,
      });
      for (const score of scoreRows.map(mapScore)) {
        if (score.id) {
          await robleClient.deleteById('assessment_scores', score.id);
        }
      }
      await robleClient.deleteById('assessment_peer_reviews', reviewId);
    }

    for (const submission of submissions) {
      if (submission.id) {
        await robleClient.deleteById('assessment_submissions', submission.id);
      }
    }

    const criteria = await loadAssessmentCriterionDetails(trimmed);
    for (const criterionDetail of criteria) {
      for (const level of criterionDetail.levels) {
        if (level.id) {
          await robleClient.deleteById('assessment_criterion_levels', level.id);
        }
      }
      if (criterionDetail.criterion.id) {
        await robleClient.deleteById('assessment_criteria', criterionDetail.criterion.id);
      }
    }

    await robleClient.deleteById('assessments', trimmed);
  },
};
