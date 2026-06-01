import {
  StudentAssessmentAssignment,
  StudentCourseEnrollment,
  StudentResultsSummary,
} from '../entities/studentModels';

export type StudentRepository = {
  getStudentEnrollments: (
    studentEmail: string,
  ) => Promise<StudentCourseEnrollment[]>;
  getStudentAssessments: (
    studentEmail: string,
  ) => Promise<StudentAssessmentAssignment[]>;
  getStudentResults: (studentEmail: string) => Promise<StudentResultsSummary>;
  submitStudentAssessment: (
    assignment: StudentAssessmentAssignment,
    scoresByReviewee: Record<string, Record<string, number>>,
  ) => Promise<void>;
};
