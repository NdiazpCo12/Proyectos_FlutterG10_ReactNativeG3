import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { BarChart3, ClipboardList, Home, User } from 'lucide-react-native';

import { AssessmentDetailScreen } from '../features/student/presentation/screens/AssessmentDetailScreen';
import { AssessmentsScreen } from '../features/student/presentation/screens/AssessmentsScreen';
import { HomeScreen } from '../features/student/presentation/screens/HomeScreen';
import { ProfileScreen } from '../features/student/presentation/screens/ProfileScreen';
import { ResultsScreen } from '../features/student/presentation/screens/ResultsScreen';
import { colors } from '../theme/theme';
import {
  AssessmentStackParamList,
  StudentTabsParamList,
} from './types';

const Tabs = createBottomTabNavigator<StudentTabsParamList>();
const AssessmentStack = createNativeStackNavigator<AssessmentStackParamList>();

function AssessmentsNavigator() {
  return (
    <AssessmentStack.Navigator screenOptions={{ headerShown: false }}>
      <AssessmentStack.Screen name="Assessments" component={AssessmentsScreen} />
      <AssessmentStack.Screen
        name="AssessmentDetail"
        component={AssessmentDetailScreen}
      />
    </AssessmentStack.Navigator>
  );
}

export function StudentTabs() {
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
        name="Home"
        component={HomeScreen}
        options={{ title: 'Inicio', tabBarIcon: ({ color }) => <Home color={color} size={21} /> }}
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
        name="Results"
        component={ResultsScreen}
        options={{
          title: 'Resultados',
          tabBarIcon: ({ color }) => <BarChart3 color={color} size={21} />,
        }}
      />
      <Tabs.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          title: 'Perfil',
          tabBarIcon: ({ color }) => <User color={color} size={21} />,
        }}
      />
    </Tabs.Navigator>
  );
}
