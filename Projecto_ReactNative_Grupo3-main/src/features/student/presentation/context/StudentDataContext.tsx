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
  emptyStudentResultsSummary,
  StudentAssessmentAssignment,
  StudentCourseEnrollment,
  StudentResultsSummary,
} from '../../domain/entities/studentModels';
import { studentRepository } from '../../data/repositories/studentRepositoryImpl';
import { useAuth } from '../../../auth/presentation/context/AuthContext';

type StudentDataContextValue = {
  courses: StudentCourseEnrollment[];
  assessments: StudentAssessmentAssignment[];
  results: StudentResultsSummary;
  isLoadingCourses: boolean;
  isLoadingAssessments: boolean;
  isLoadingResults: boolean;
  error?: string;
  refreshAll: () => Promise<void>;
  refreshCourses: () => Promise<void>;
  refreshAssessments: () => Promise<void>;
  refreshResults: () => Promise<void>;
  submitAssessment: (
    assignment: StudentAssessmentAssignment,
    scores: Record<string, Record<string, number>>,
  ) => Promise<void>;
};

const StudentDataContext = createContext<StudentDataContextValue | undefined>(
  undefined,
);

export function StudentDataProvider({ children }: PropsWithChildren) {
  const { user } = useAuth();
  const email = user?.email ?? '';
  const [courses, setCourses] = useState<StudentCourseEnrollment[]>([]);
  const [assessments, setAssessments] = useState<StudentAssessmentAssignment[]>(
    [],
  );
  const [results, setResults] = useState<StudentResultsSummary>(
    emptyStudentResultsSummary,
  );
  const [isLoadingCourses, setIsLoadingCourses] = useState(false);
  const [isLoadingAssessments, setIsLoadingAssessments] = useState(false);
  const [isLoadingResults, setIsLoadingResults] = useState(false);
  const [error, setError] = useState<string | undefined>();

  const refreshCourses = useCallback(async () => {
    setIsLoadingCourses(true);
    try {
      setCourses(await studentRepository.getStudentEnrollments(email));
      setError(undefined);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudieron cargar cursos.');
    } finally {
      setIsLoadingCourses(false);
    }
  }, [email]);

  const refreshAssessments = useCallback(async () => {
    setIsLoadingAssessments(true);
    try {
      setAssessments(await studentRepository.getStudentAssessments(email));
      setError(undefined);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : 'No se pudieron cargar evaluaciones.',
      );
    } finally {
      setIsLoadingAssessments(false);
    }
  }, [email]);

  const refreshResults = useCallback(async () => {
    setIsLoadingResults(true);
    try {
      setResults(await studentRepository.getStudentResults(email));
      setError(undefined);
    } catch (err) {
      setResults(emptyStudentResultsSummary);
      setError(
        err instanceof Error ? err.message : 'No se pudieron cargar resultados.',
      );
    } finally {
      setIsLoadingResults(false);
    }
  }, [email]);

  const refreshAll = useCallback(async () => {
    await Promise.all([refreshCourses(), refreshAssessments(), refreshResults()]);
  }, [refreshAssessments, refreshCourses, refreshResults]);

  useEffect(() => {
    if (email) {
      refreshAll();
    }
  }, [email, refreshAll]);

  const value = useMemo<StudentDataContextValue>(
    () => ({
      courses,
      assessments,
      results,
      isLoadingCourses,
      isLoadingAssessments,
      isLoadingResults,
      error,
      refreshAll,
      refreshCourses,
      refreshAssessments,
      refreshResults,
      async submitAssessment(assignment, scores) {
        await studentRepository.submitStudentAssessment(assignment, scores);
        await Promise.all([refreshAssessments(), refreshResults()]);
      },
    }),
    [
      assessments,
      courses,
      error,
      isLoadingAssessments,
      isLoadingCourses,
      isLoadingResults,
      refreshAll,
      refreshAssessments,
      refreshCourses,
      refreshResults,
      results,
    ],
  );

  return (
    <StudentDataContext.Provider value={value}>
      {children}
    </StudentDataContext.Provider>
  );
}

export const useStudentData = () => {
  const value = useContext(StudentDataContext);
  if (!value) {
    throw new Error('useStudentData must be used inside StudentDataProvider');
  }
  return value;
};
