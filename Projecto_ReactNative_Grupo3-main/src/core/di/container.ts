import { authRepository } from '../../features/auth/data/repositories/authRepositoryImpl';
import { studentRepository } from '../../features/student/data/repositories/studentRepositoryImpl';
import { teacherRepository } from '../../features/teacher/data/repositories/teacherRepositoryImpl';
import { sessionStorage } from '../local/LocalPreferencesAsyncStorage';

export const container = {
  authRepository,
  studentRepository,
  teacherRepository,
  localPreferences: sessionStorage,
};
