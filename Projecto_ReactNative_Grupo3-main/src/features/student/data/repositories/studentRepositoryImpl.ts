import { StudentRepository } from '../../domain/repositories/studentRepository';
import { studentService } from '../datasources/studentDatasource';

export const studentRepository: StudentRepository = {
  getStudentEnrollments: studentService.getStudentEnrollments,
  getStudentAssessments: studentService.getStudentAssessments,
  getStudentResults: studentService.getStudentResults,
  submitStudentAssessment: studentService.submitStudentAssessment.bind(
    studentService,
  ),
};
