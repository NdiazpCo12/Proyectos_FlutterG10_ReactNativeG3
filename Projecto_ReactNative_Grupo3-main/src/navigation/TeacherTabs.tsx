import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { BarChart3, BookOpen, ClipboardList, Home, User } from 'lucide-react-native';

import { TeacherHomeScreen } from '../features/teacher/presentation/screens/TeacherHomeScreen';
import { TeacherCourseDetailScreen } from '../features/teacher/presentation/screens/TeacherCourseDetailScreen';
import { TeacherCoursesScreen } from '../features/teacher/presentation/screens/TeacherCoursesScreen';
import { CsvImportPreviewScreen } from '../features/teacher/presentation/screens/CsvImportPreviewScreen';
import { TeacherCreateCourseScreen } from '../features/teacher/presentation/screens/TeacherCreateCourseScreen';
import { TeacherAssessmentDetailScreen } from '../features/teacher/presentation/screens/TeacherAssessmentDetailScreen';
import { TeacherAssessmentsScreen } from '../features/teacher/presentation/screens/TeacherAssessmentsScreen';
import { TeacherAssessmentBuilderScreen } from '../features/teacher/presentation/screens/TeacherAssessmentBuilderScreen';
import { TeacherReportsScreen } from '../features/teacher/presentation/screens/TeacherReportsScreen';
import { TeacherProfileScreen } from '../features/teacher/presentation/screens/TeacherProfileScreen';
import { colors } from '../theme/theme';
import {
  TeacherAssessmentsStackParamList,
  TeacherCoursesStackParamList,
  TeacherReportsStackParamList,
  TeacherTabsParamList,
} from './types';

const Tabs = createBottomTabNavigator<TeacherTabsParamList>();
const CoursesStack = createNativeStackNavigator<TeacherCoursesStackParamList>();
const AssessmentsStack =
  createNativeStackNavigator<TeacherAssessmentsStackParamList>();
const ReportsStack = createNativeStackNavigator<TeacherReportsStackParamList>();

function CoursesNavigator() {
  return (
    <CoursesStack.Navigator screenOptions={{ headerShown: false }}>
      <CoursesStack.Screen
        name="TeacherCourses"
        component={TeacherCoursesScreen}
      />
      <CoursesStack.Screen
        name="TeacherCreateCourse"
        component={TeacherCreateCourseScreen}
      />
      <CoursesStack.Screen
        name="TeacherCourseDetail"
        component={TeacherCourseDetailScreen}
      />
      <CoursesStack.Screen
        name="CsvImportPreview"
        component={CsvImportPreviewScreen}
      />
    </CoursesStack.Navigator>
  );
}

function AssessmentsNavigator() {
  return (
    <AssessmentsStack.Navigator screenOptions={{ headerShown: false }}>
      <AssessmentsStack.Screen
        name="TeacherAssessments"
        component={TeacherAssessmentsScreen}
      />
      <AssessmentsStack.Screen
        name="TeacherAssessmentDetail"
        component={TeacherAssessmentDetailScreen}
      />
      <AssessmentsStack.Screen
        name="TeacherAssessmentBuilder"
        component={TeacherAssessmentBuilderScreen}
      />
    </AssessmentsStack.Navigator>
  );
}

function ReportsNavigator() {
  return (
    <ReportsStack.Navigator screenOptions={{ headerShown: false }}>
      <ReportsStack.Screen
        name="TeacherReports"
        component={TeacherReportsScreen}
      />
      <ReportsStack.Screen
        name="TeacherAssessmentDetail"
        component={TeacherAssessmentDetailScreen}
      />
      <ReportsStack.Screen
        name="TeacherAssessmentBuilder"
        component={TeacherAssessmentBuilderScreen}
      />
    </ReportsStack.Navigator>
  );
}

export function TeacherTabs() {
  return (
    <Tabs.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.muted,
        tabBarStyle: {
          backgroundColor: colors.surface,
          borderTopColor: colors.border,
          height: 64,
          paddingBottom: 8,
          paddingTop: 8,
        },
        tabBarLabelStyle: { fontWeight: '700' },
      }}
    >
      <Tabs.Screen
        name="TeacherHome"
        component={TeacherHomeScreen}
        options={{
          title: 'Inicio',
          tabBarIcon: ({ color }) => <Home color={color} size={21} />,
        }}
      />
      <Tabs.Screen
        name="CoursesStack"
        component={CoursesNavigator}
        options={{
          title: 'Cursos',
          tabBarIcon: ({ color }) => <BookOpen color={color} size={21} />,
        }}
      />
      <Tabs.Screen
        name="AssessmentsStack"
        component={AssessmentsNavigator}
        options={{
          title: 'Evaluaciones',
          tabBarIcon: ({ color }) => <ClipboardList color={color} size={21} />,
        }}
      />
      <Tabs.Screen
        name="Reports"
        component={ReportsNavigator}
        options={{
          title: 'Reportes',
          tabBarIcon: ({ color }) => <BarChart3 color={color} size={21} />,
        }}
      />
      <Tabs.Screen
        name="Profile"
        component={TeacherProfileScreen}
        options={{
          title: 'Perfil',
          tabBarIcon: ({ color }) => <User color={color} size={21} />,
        }}
      />
    </Tabs.Navigator>
  );
}
