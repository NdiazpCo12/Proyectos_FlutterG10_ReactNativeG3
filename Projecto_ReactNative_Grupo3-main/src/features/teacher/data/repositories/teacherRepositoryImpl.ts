import { TeacherRepository } from '../../domain/repositories/teacherRepository';
import { teacherService } from '../datasources/teacherDatasource';

export const teacherRepository: TeacherRepository = {
  getTeacherCourses: teacherService.getTeacherCourses,
  createOrResolveCourse: teacherService.createOrResolveCourse,
  getTeacherAssessments: teacherService.getTeacherAssessments,
  getCourseCategories: teacherService.getCourseCategories,
  getAssessmentDetail: teacherService.getAssessmentDetail,
  getAssessmentAnalytics: teacherService.getAssessmentAnalytics,
  createAssessment: teacherService.createAssessment,
  updateAssessment: teacherService.updateAssessment,
  importCourseCsv: teacherService.importCourseCsv.bind(teacherService),
  deleteAssessment: teacherService.deleteAssessment,
};
