import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { ActivityIndicator, StyleSheet, View } from 'react-native';

import { colors } from '../theme/theme';
import { useAuth } from '../features/auth/presentation/context/AuthContext';
import { isTeacherRole } from '../features/auth/domain/entities/appRole';
import { LoginScreen } from '../features/auth/presentation/screens/LoginScreen';
import { StudentDataProvider } from '../features/student/presentation/context/StudentDataContext';
import { StudentTabs } from './StudentTabs';
import { TeacherDataProvider } from '../features/teacher/presentation/context/TeacherDataContext';
import { TeacherTabs } from './TeacherTabs';
import { RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();

const navTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: colors.background,
  },
};

export function RootNavigator() {
  const { user, appRole, isBootstrapping } = useAuth();

  if (isBootstrapping) {
    return (
      <View style={styles.boot}>
        <ActivityIndicator color={colors.primary} />
      </View>
    );
  }

  const isTeacher = isTeacherRole(appRole);

  return (
    <NavigationContainer theme={navTheme}>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          isTeacher ? (
            <Stack.Screen name="Teacher">
              {() => (
                <TeacherDataProvider>
                  <TeacherTabs />
                </TeacherDataProvider>
              )}
            </Stack.Screen>
          ) : (
            <Stack.Screen name="Student">
              {() => (
                <StudentDataProvider>
                  <StudentTabs />
                </StudentDataProvider>
              )}
            </Stack.Screen>
          )
        ) : (
          <Stack.Screen name="Login" component={LoginScreen} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  boot: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.background,
  },
});
