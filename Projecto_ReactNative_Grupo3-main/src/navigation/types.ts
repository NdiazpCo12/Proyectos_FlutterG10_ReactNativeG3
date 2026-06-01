import { NavigatorScreenParams } from '@react-navigation/native';

export type RootStackParamList = {
  Login: undefined;
  Student: undefined;
  Teacher: undefined;
};

export type StudentTabsParamList = {
  Home: undefined;
  AssessmentsStack: undefined;
  Results: undefined;
  Profile: undefined;
};

export type AssessmentStackParamList = {
  Assessments: undefined;
  AssessmentDetail: { assessmentId: string; groupId: string };
};

// ── Teacher navigation types ──

export type TeacherTabsParamList = {
  TeacherHome: undefined;
  CoursesStack: NavigatorScreenParams<TeacherCoursesStackParamList> | undefined;
  AssessmentsStack: undefined;
  Reports: undefined;
  Profile: undefined;
};

export type TeacherCoursesStackParamList = {
  TeacherCourses: undefined;
  TeacherCreateCourse: undefined;
  TeacherCourseDetail: { courseId: string };
  CsvImportPreview:
    | {
        courseId?: string;
        initialCourseName?: string;
        initialCourseCode?: string;
      }
    | undefined;
};

export type TeacherAssessmentsStackParamList = {
  TeacherAssessments: undefined;
  TeacherAssessmentDetail: { assessmentId: string };
  TeacherAssessmentBuilder:
    | { mode: 'create'; courseId?: string }
    | { mode: 'edit'; assessmentId: string };
};

export type TeacherReportsStackParamList = {
  TeacherReports: undefined;
  TeacherAssessmentDetail: { assessmentId: string };
  TeacherAssessmentBuilder:
    | { mode: 'create'; courseId?: string }
    | { mode: 'edit'; assessmentId: string };
};
