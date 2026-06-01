export type AppRole = 'student' | 'teacher' | 'unknown';

export const resolveAppRole = (role: string): AppRole => {
  const normalized = role.trim().toLowerCase();
  if (
    normalized === 'estudiante' ||
    normalized === 'student' ||
    normalized === 'alumno'
  ) {
    return 'student';
  }
  if (
    normalized === 'teacher' ||
    normalized === 'docente' ||
    normalized === 'profesor' ||
    normalized === 'admin'
  ) {
    return 'teacher';
  }
  return 'unknown';
};

export const isStudentRole = (role: AppRole) => role === 'student';
export const isTeacherRole = (role: AppRole) => role === 'teacher';
