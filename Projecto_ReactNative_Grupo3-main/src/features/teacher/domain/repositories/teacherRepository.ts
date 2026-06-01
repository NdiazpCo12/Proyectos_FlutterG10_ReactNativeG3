import {
  CreateTeacherAssessmentInput,
  TeacherAssessmentAnalytics,
  TeacherAssessmentDetail,
  TeacherCreateCourseInput,
  TeacherCreateCourseResult,
  TeacherAssessmentOverview,
  TeacherCourseCategory,
  TeacherCourseSummary,
  TeacherCsvImportInput,
  TeacherCsvImportResult,
  UpdateTeacherAssessmentInput,
} from '../entities/teacherModels';

export type TeacherRepository = {
  getTeacherCourses(email: string): Promise<TeacherCourseSummary[]>;
  createOrResolveCourse(
    input: TeacherCreateCourseInput,
  ): Promise<TeacherCreateCourseResult>;
  getTeacherAssessments(
    email: string,
  ): Promise<TeacherAssessmentOverview[]>;
  getCourseCategories(courseId: string): Promise<TeacherCourseCategory[]>;
  getAssessmentDetail(
    assessmentId: string,
  ): Promise<TeacherAssessmentDetail | null>;
  getAssessmentAnalytics(
    assessmentId: string,
  ): Promise<TeacherAssessmentAnalytics | null>;
  createAssessment(
    input: CreateTeacherAssessmentInput,
  ): Promise<string>;
  updateAssessment(
    input: UpdateTeacherAssessmentInput,
  ): Promise<void>;
  importCourseCsv(
    input: TeacherCsvImportInput,
  ): Promise<TeacherCsvImportResult>;
  deleteAssessment(assessmentId: string): Promise<void>;
};
