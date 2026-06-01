import {
  isStudentRole,
  isTeacherRole,
  defaultUserPassword,
} from './authDatasource';

// ── isStudentRole ──

describe('isStudentRole', () => {
  it('returns true for "estudiante"', () => {
    expect(isStudentRole('estudiante')).toBe(true);
  });

  it('returns true for "student"', () => {
    expect(isStudentRole('student')).toBe(true);
  });

  it('returns true for "alumno"', () => {
    expect(isStudentRole('alumno')).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isStudentRole('Student')).toBe(true);
    expect(isStudentRole('ESTUDIANTE')).toBe(true);
    expect(isStudentRole('Alumno')).toBe(true);
  });

  it('returns false for "teacher"', () => {
    expect(isStudentRole('teacher')).toBe(false);
  });

  it('returns false for an unrecognised role', () => {
    expect(isStudentRole('admin')).toBe(false);
  });

  it('returns false for an empty string', () => {
    expect(isStudentRole('')).toBe(false);
  });

  it('handles whitespace-padded input', () => {
    expect(isStudentRole('  student  ')).toBe(true);
  });
});

// ── isTeacherRole ──

describe('isTeacherRole', () => {
  it('returns true for "teacher"', () => {
    expect(isTeacherRole('teacher')).toBe(true);
  });

  it('returns true for "docente"', () => {
    expect(isTeacherRole('docente')).toBe(true);
  });

  it('returns true for "profesor"', () => {
    expect(isTeacherRole('profesor')).toBe(true);
  });

  it('returns true for "admin"', () => {
    expect(isTeacherRole('admin')).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isTeacherRole('Teacher')).toBe(true);
    expect(isTeacherRole('DOCENTE')).toBe(true);
    expect(isTeacherRole('Admin')).toBe(true);
  });

  it('returns false for "student"', () => {
    expect(isTeacherRole('student')).toBe(false);
  });

  it('returns false for an empty string', () => {
    expect(isTeacherRole('')).toBe(false);
  });

  it('handles whitespace-padded input', () => {
    expect(isTeacherRole('  admin  ')).toBe(true);
  });
});

// ── defaultUserPassword ──

describe('defaultUserPassword', () => {
  it('is a non-empty string', () => {
    expect(typeof defaultUserPassword).toBe('string');
    expect(defaultUserPassword.length).toBeGreaterThan(0);
  });

  it('is the expected constant value', () => {
    expect(defaultUserPassword).toBe('ThePassword!1');
  });
});
