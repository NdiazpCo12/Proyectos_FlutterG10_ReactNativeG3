import {
  JsonRecord,
  RobleAssessment,
  RobleAssessmentCriterion,
  RobleAssessmentCriterionLevel,
  RobleAssessmentPeerReview,
  RobleAssessmentScore,
  RobleAssessmentSubmission,
  RobleCourseGroupRecord,
  RobleCourseHome,
  RobleGroupCategoryRecord,
  RobleGroupMemberRecord,
  RobleStudentRecord,
} from './models';
import { normalizeDisplayText } from '../../utils/text';

const text = (value: unknown, fallback = '') =>
  normalizeDisplayText(value, fallback);

const num = (value: unknown, fallback = 0) => {
  const parsed = Number.parseInt(text(value), 10);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const date = (value: unknown, fallback = new Date()) => {
  const parsed = Date.parse(text(value));
  return Number.isNaN(parsed) ? fallback : new Date(parsed);
};

export const optionalDate = (value: unknown) => {
  const raw = text(value).trim();
  if (!raw) return undefined;
  const parsed = Date.parse(raw);
  return Number.isNaN(parsed) ? undefined : new Date(parsed);
};

const id = (json: JsonRecord) => text(json._id ?? json.id);

export const mapCourse = (json: JsonRecord): RobleCourseHome => ({
  id: id(json),
  name: text(json.name, 'No Name'),
  code: text(json.code, 'No Code'),
  teacherEmail: text(json.teacher_email),
  createdAt: date(json.created_at),
  status: text(json.status, 'Active'),
  studentCount: num(json.student_count, 25),
  pendingEvaluations: num(json.pending_evaluations, 3),
});

export const mapStudent = (json: JsonRecord): RobleStudentRecord => ({
  id: id(json),
  username: text(json.username),
  orgDefinedId: text(json.org_defined_id),
  firstName: text(json.first_name),
  lastName: text(json.last_name),
  email: text(json.email),
});

export const mapGroupMember = (json: JsonRecord): RobleGroupMemberRecord => ({
  id: id(json),
  groupId: text(json.group_id),
  studentId: text(json.student_id),
  enrollmentDate: text(json.enrollment_date),
});

export const mapCourseGroup = (json: JsonRecord): RobleCourseGroupRecord => ({
  id: id(json),
  courseId: text(json.course_id),
  categoryId: text(json.category_id),
  groupName: text(json.group_name),
  groupCode: text(json.group_code),
});

export const mapGroupCategory = (
  json: JsonRecord,
): RobleGroupCategoryRecord => ({
  id: id(json),
  courseId: text(json.course_id),
  name: text(json.name),
});

export const mapAssessment = (json: JsonRecord): RobleAssessment => {
  const now = new Date();
  return {
    id: id(json) || undefined,
    courseId: text(json.course_id),
    categoryId: text(json.category_id),
    name: text(json.name, 'Untitled assessment'),
    visibility: text(json.visibility, 'private'),
    status: text(json.status, 'draft'),
    startsAt: date(json.starts_at, now),
    endsAt: date(json.ends_at, new Date(now.getTime() + 7 * 86400000)),
    createdByEmail: text(json.created_by_email),
    createdAt: date(json.created_at, now),
  };
};

export const mapCriterion = (json: JsonRecord): RobleAssessmentCriterion => ({
  id: id(json) || undefined,
  assessmentId: text(json.assessment_id),
  name: text(json.name, 'Criterion'),
  description: text(json.description),
  weight: num(json.weight),
  displayOrder: num(json.display_order),
  createdAt: date(json.created_at),
});

export const mapCriterionLevel = (
  json: JsonRecord,
): RobleAssessmentCriterionLevel => ({
  id: id(json) || undefined,
  criterionId: text(json.criterion_id),
  scoreValue: num(json.score_value),
  label: text(json.label),
  descriptionEn: text(json.description_en),
  descriptionEs: text(json.description_es),
  displayOrder: num(json.display_order),
});

export const mapSubmission = (
  json: JsonRecord,
): RobleAssessmentSubmission => ({
  id: id(json) || undefined,
  assessmentId: text(json.assessment_id),
  courseId: text(json.course_id),
  categoryId: text(json.category_id),
  groupId: text(json.group_id),
  reviewerStudentId: text(json.reviewer_student_id),
  status: text(json.status, 'pending'),
  generalComment: text(json.general_comment),
  startedAt: optionalDate(json.started_at),
  submittedAt: optionalDate(json.submitted_at),
  createdAt: optionalDate(json.created_at) ?? new Date(),
});

export const mapPeerReview = (
  json: JsonRecord,
): RobleAssessmentPeerReview => ({
  id: id(json) || undefined,
  submissionId: text(json.submission_id),
  assessmentId: text(json.assessment_id),
  courseId: text(json.course_id),
  categoryId: text(json.category_id),
  groupId: text(json.group_id),
  reviewerStudentId: text(json.reviewer_student_id),
  revieweeStudentId: text(json.reviewee_student_id),
  generalComment: text(json.general_comment),
  createdAt: optionalDate(json.created_at) ?? new Date(),
});

export const mapScore = (json: JsonRecord): RobleAssessmentScore => ({
  id: id(json) || undefined,
  peerReviewId: text(json.peer_review_id),
  assessmentId: text(json.assessment_id),
  courseId: text(json.course_id),
  categoryId: text(json.category_id),
  groupId: text(json.group_id),
  reviewerStudentId: text(json.reviewer_student_id),
  revieweeStudentId: text(json.reviewee_student_id),
  criterionId: text(json.criterion_id),
  scoreValue: num(json.score_value),
  createdAt: optionalDate(json.created_at) ?? new Date(),
  updatedAt: optionalDate(json.updated_at) ?? new Date(),
});

export const submissionToJson = (submission: RobleAssessmentSubmission) => ({
  assessment_id: submission.assessmentId,
  course_id: submission.courseId,
  category_id: submission.categoryId,
  group_id: submission.groupId,
  reviewer_student_id: submission.reviewerStudentId,
  status: submission.status,
  general_comment: submission.generalComment,
  started_at: submission.startedAt?.toISOString() ?? '',
  submitted_at: submission.submittedAt?.toISOString() ?? '',
  created_at: submission.createdAt.toISOString(),
});

export const peerReviewToJson = (review: RobleAssessmentPeerReview) => ({
  submission_id: review.submissionId,
  assessment_id: review.assessmentId,
  course_id: review.courseId,
  category_id: review.categoryId,
  group_id: review.groupId,
  reviewer_student_id: review.reviewerStudentId,
  reviewee_student_id: review.revieweeStudentId,
  general_comment: review.generalComment,
  created_at: review.createdAt.toISOString(),
});

export const scoreToJson = (score: RobleAssessmentScore) => ({
  peer_review_id: score.peerReviewId,
  assessment_id: score.assessmentId,
  course_id: score.courseId,
  category_id: score.categoryId,
  group_id: score.groupId,
  reviewer_student_id: score.reviewerStudentId,
  reviewee_student_id: score.revieweeStudentId,
  criterion_id: score.criterionId,
  score_value: score.scoreValue,
  created_at: score.createdAt.toISOString(),
  updated_at: score.updatedAt.toISOString(),
});
