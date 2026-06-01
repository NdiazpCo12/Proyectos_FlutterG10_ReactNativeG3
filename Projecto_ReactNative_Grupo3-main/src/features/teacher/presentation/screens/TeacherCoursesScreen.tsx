import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { BookOpen } from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { SurfaceCard } from '../../../../components/ui';
import { TeacherCoursesStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = NativeStackScreenProps<
  TeacherCoursesStackParamList,
  'TeacherCourses'
>;

export function TeacherCoursesScreen({ navigation }: Props) {
  const { courses, isLoadingCourses } = useTeacherData();

  return (
    <Screen>
      <HeaderBand>
        <View style={styles.headerRow}>
          <Text style={styles.headerTitle}>Mis Cursos</Text>
          <Pressable onPress={() => navigation.navigate('TeacherCreateCourse')}>
            <Text style={styles.headerAction}>Crear curso</Text>
          </Pressable>
        </View>
      </HeaderBand>
      {isLoadingCourses ? (
        <View style={styles.centered}>
          <Text style={styles.empty}>Cargando...</Text>
        </View>
      ) : (
        <FlatList
          data={courses}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          ListEmptyComponent={
            <View style={styles.centered}>
              <BookOpen color={colors.muted} size={40} />
              <Text style={styles.empty}>No tenés cursos asignados</Text>
            </View>
          }
          renderItem={({ item }) => (
            <Pressable
              onPress={() =>
                navigation.navigate('TeacherCourseDetail', {
                  courseId: item.id,
                })
              }
            >
              <SurfaceCard>
                <View style={styles.cardRow}>
                  <View style={styles.cardInfo}>
                    <Text style={styles.courseName}>{item.name}</Text>
                    <Text style={styles.courseCode}>
                      {item.code} · {item.studentCount} estudiantes
                    </Text>
                  </View>
                  <View
                    style={[
                      styles.badge,
                      item.status === 'Active'
                        ? styles.badgeActive
                        : styles.badgeInactive,
                    ]}
                  >
                    <Text style={styles.badgeText}>
                      {item.status === 'Active' ? 'Activo' : item.status}
                    </Text>
                  </View>
                </View>
              </SurfaceCard>
            </Pressable>
          )}
        />
      )}
    </Screen>
  );
}

const styles = StyleSheet.create({
  headerTitle: {
    color: '#FFFFFF',
    fontSize: 24,
    fontWeight: '900',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.md,
  },
  headerAction: {
    color: '#FFFFFF',
    fontWeight: '800',
  },
  list: {
    padding: spacing.lg,
    gap: spacing.md,
  },
  centered: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 80,
    gap: spacing.sm,
  },
  empty: {
    color: colors.muted,
    fontSize: 16,
  },
  cardRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  cardInfo: { flex: 1 },
  courseName: {
    fontSize: 16,
    fontWeight: '800',
    color: '#111827',
  },
  courseCode: {
    fontSize: 13,
    color: colors.muted,
    marginTop: 3,
  },
  badge: {
    borderRadius: 10,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  badgeActive: { backgroundColor: colors.primarySoft },
  badgeInactive: { backgroundColor: colors.tint },
  badgeText: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.primary,
  },
});
