export type {
  JsonRecord,
  RobleCourseHome,
  RobleStudentRecord,
  RobleGroupMemberRecord,
  RobleCourseGroupRecord,
  RobleGroupCategoryRecord,
  RobleAssessment,
  RobleAssessmentCriterion,
  RobleAssessmentCriterionLevel,
  RobleAssessmentSubmission,
  RobleAssessmentPeerReview,
  RobleAssessmentScore,
} from '../../../../core/roble/models';

import type {
  RobleAssessment,
  RobleAssessmentCriterion,
  RobleAssessmentCriterionLevel,
  RobleAssessmentSubmission,
  RobleCourseGroupRecord,
  RobleCourseHome,
  RobleGroupCategoryRecord,
  RobleStudentRecord,
} from '../../../../core/roble/models';

export type RobleAssessmentCriterionDetail = {
  criterion: RobleAssessmentCriterion;
  levels: RobleAssessmentCriterionLevel[];
};

export type StudentCourseEnrollment = {
  course: RobleCourseHome;
  groupName: string;
  groupCode: string;
  groupCategoryName: string;
  enrollmentDate: string;
};

export type StudentAssessmentTeammate = {
  studentId: string;
  name: string;
  email: string;
};

export type StudentAssessmentAssignment = {
  assessment: RobleAssessment;
  course: RobleCourseHome;
  category?: RobleGroupCategoryRecord;
  group: RobleCourseGroupRecord;
  reviewer: RobleStudentRecord;
  teammates: StudentAssessmentTeammate[];
  criteria: RobleAssessmentCriterionDetail[];
  isSubmitted: boolean;
  submissionId?: string;
  submissionStatus?: string;
  submittedAt?: Date;
  savedScoresByReviewee: Record<string, Record<string, number>>;
  statusLabel: string;
  categoryName: string;
  canSubmit: boolean;
};

export type StudentResultCriterionScore = {
  label: string;
  score: number;
  responseCount: number;
  displayOrder: number;
};

export type StudentAssessmentHistoryItem = {
  assessmentId: string;
  title: string;
  date: Date;
  score: number;
  reviewCount: number;
  criteria: StudentResultCriterionScore[];
};

export type StudentCourseResults = {
  courseId: string;
  courseName: string;
  courseCode: string;
  overallScore: number;
  assessmentCount: number;
  reviewCount: number;
  criteria: StudentResultCriterionScore[];
  history: StudentAssessmentHistoryItem[];
  displayLabel: string;
  hasResults: boolean;
};

export type StudentResultsSummary = {
  overallScore: number;
  assessmentCount: number;
  reviewCount: number;
  criteria: StudentResultCriterionScore[];
  history: StudentAssessmentHistoryItem[];
  courseResults: StudentCourseResults[];
  hasResults: boolean;
};

export const emptyStudentResultsSummary: StudentResultsSummary = {
  overallScore: 0,
  assessmentCount: 0,
  reviewCount: 0,
  criteria: [],
  history: [],
  courseResults: [],
  hasResults: false,
};
