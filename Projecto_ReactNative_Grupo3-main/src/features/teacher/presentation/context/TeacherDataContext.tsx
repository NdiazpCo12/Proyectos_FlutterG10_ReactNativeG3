import {
  createContext,
  PropsWithChildren,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';

import {
  TeacherAssessmentOverview,
  TeacherCreateCourseResult,
  TeacherCourseSummary,
} from '../../domain/entities/teacherModels';
import { teacherRepository } from '../../data/repositories/teacherRepositoryImpl';
import { useAuth } from '../../../auth/presentation/context/AuthContext';

type TeacherDataContextValue = {
  courses: TeacherCourseSummary[];
  assessments: TeacherAssessmentOverview[];
  isLoadingCourses: boolean;
  isLoadingAssessments: boolean;
  error?: string;
  createOrResolveCourse: (
    name: string,
    code?: string,
  ) => Promise<TeacherCreateCourseResult>;
  refreshAll: () => Promise<void>;
  refreshCourses: () => Promise<void>;
  refreshAssessments: () => Promise<void>;
};

const TeacherDataContext = createContext<TeacherDataContextValue | undefined>(
  undefined,
);

export function TeacherDataProvider({ children }: PropsWithChildren) {
  const { user } = useAuth();
  const email = user?.email ?? '';
  const [courses, setCourses] = useState<TeacherCourseSummary[]>([]);
  const [assessments, setAssessments] = useState<TeacherAssessmentOverview[]>(
    [],
  );
  const [isLoadingCourses, setIsLoadingCourses] = useState(false);
  const [isLoadingAssessments, setIsLoadingAssessments] = useState(false);
  const [error, setError] = useState<string | undefined>();

  const refreshCourses = useCallback(async () => {
    if (!email) return;
    setIsLoadingCourses(true);
    try {
      setCourses(await teacherRepository.getTeacherCourses(email));
      setError(undefined);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : 'No se pudieron cargar cursos.',
      );
    } finally {
      setIsLoadingCourses(false);
    }
  }, [email]);

  const refreshAssessments = useCallback(async () => {
    if (!email) return;
    setIsLoadingAssessments(true);
    try {
      setAssessments(
        await teacherRepository.getTeacherAssessments(email),
      );
      setError(undefined);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : 'No se pudieron cargar evaluaciones.',
      );
    } finally {
      setIsLoadingAssessments(false);
    }
  }, [email]);

  const createOrResolveCourse = useCallback(
    async (name: string, code?: string) => {
      if (!email.trim()) {
        throw new Error('No encontramos el correo del docente autenticado.');
      }

      const result = await teacherRepository.createOrResolveCourse({
        email,
        name,
        code,
      });
      await refreshCourses();
      return result;
    },
    [email, refreshCourses],
  );

  const refreshAll = useCallback(async () => {
    await Promise.all([refreshCourses(), refreshAssessments()]);
  }, [refreshCourses, refreshAssessments]);

  useEffect(() => {
    if (email) {
      refreshAll();
    }
  }, [email, refreshAll]);

  const value = useMemo<TeacherDataContextValue>(
    () => ({
      courses,
      assessments,
      createOrResolveCourse,
      isLoadingCourses,
      isLoadingAssessments,
      error,
      refreshAll,
      refreshCourses,
      refreshAssessments,
    }),
    [
      assessments,
      createOrResolveCourse,
      courses,
      error,
      isLoadingAssessments,
      isLoadingCourses,
      refreshAll,
      refreshAssessments,
      refreshCourses,
    ],
  );

  return (
    <TeacherDataContext.Provider value={value}>
      {children}
    </TeacherDataContext.Provider>
  );
}

export const useTeacherData = () => {
  const value = useContext(TeacherDataContext);
  if (!value) {
    throw new Error(
      'useTeacherData must be used inside TeacherDataProvider',
    );
  }
  return value;
};
