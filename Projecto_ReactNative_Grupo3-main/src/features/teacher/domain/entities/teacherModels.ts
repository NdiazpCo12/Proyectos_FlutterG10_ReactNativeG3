import type {
  RobleAssessment,
  RobleAssessmentCriterion,
  RobleAssessmentCriterionLevel,
} from '../../../../core/roble/models';

// ── Teacher-specific domain models ──

export type TeacherCourseSummary = {
  id: string;
  name: string;
  code: string;
  teacherEmail: string;
  status: string;
  studentCount: number;
  createdAt: Date;
};

export type TeacherCreateCourseInput = {
  email: string;
  name: string;
  code?: string;
};

export type TeacherCreateCourseResult = {
  id: string;
  name: string;
  code: string;
  created: boolean;
};

export type TeacherAssessmentOverview = {
  assessment: RobleAssessment;
  courseName: string;
  courseCode: string;
  submissionCount: number;
  groupCount: number;
};

export type TeacherCourseCategory = {
  id: string;
  name: string;
  groupCount: number;
};

export type TeacherAssessmentCriterionDetail = {
  criterion: RobleAssessmentCriterion;
  levels: RobleAssessmentCriterionLevel[];
};

export type TeacherAssessmentDetail = {
  assessment: RobleAssessment;
  courseName: string;
  courseCode: string;
  categoryName: string;
  totalReviewers: number;
  responsesSubmitted: number;
  criteria: TeacherAssessmentCriterionDetail[];
};

export type TeacherStudentAnalytics = {
  studentId: string;
  name: string;
  email: string;
  averageScore: number;
};

export type TeacherGroupAnalytics = {
  groupId: string;
  groupName: string;
  studentCount: number;
  submissionCount: number;
  completedCount: number;
  averageScore: number;
  students: TeacherStudentAnalytics[];
};

export type TeacherAssessmentAnalytics = {
  assessmentId: string;
  assessmentName: string;
  courseId: string;
  courseName: string;
  courseCode: string;
  totalGroups: number;
  totalStudents: number;
  totalSubmissions: number;
  completedSubmissions: number;
  groupBreakdown: TeacherGroupAnalytics[];
};

export type CreateTeacherAssessmentInput = {
  courseId: string;
  categoryId: string;
  name: string;
  visibility?: string;
  startsAt: Date;
  endsAt: Date;
};

export type UpdateTeacherAssessmentInput = {
  assessmentId: string;
  name: string;
  visibility?: string;
  status?: string;
  startsAt: Date;
  endsAt: Date;
};

export type TeacherCsvImportRow = {
  groupCategoryName: string;
  groupName: string;
  groupCode: string;
  username: string;
  orgDefinedId: string;
  firstName: string;
  lastName: string;
  email: string;
  enrollmentDate: string;
};

export type TeacherCsvImportInput = {
  rows: TeacherCsvImportRow[];
  courseId?: string;
  courseCode: string;
  courseName?: string;
  teacherEmail?: string;
  groupCategoryName: string;
};

export type TeacherCsvImportResult = {
  success: boolean;
  courseId?: string;
  studentCount: number;
  groupCount: number;
  errors: string[];
};
