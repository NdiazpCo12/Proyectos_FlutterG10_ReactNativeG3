import { RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';
import { BookOpen, RefreshCw, Users } from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { EmptyState, LoadingState, PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { useAuth } from '../../../auth/presentation/context/AuthContext';
import { useStudentData } from '../context/StudentDataContext';
import { colors } from '../../../../theme/theme';

export function HomeScreen() {
  const { user } = useAuth();
  const { courses, isLoadingCourses, refreshCourses, error } = useStudentData();
  const displayName = user?.name?.trim() || 'Student';

  return (
    <Screen>
      <ScrollView
        refreshControl={
          <RefreshControl refreshing={isLoadingCourses} onRefresh={refreshCourses} />
        }
        contentContainerStyle={styles.scroll}
      >
        <HeaderBand>
          <Text style={styles.title}>Welcome back, {displayName}!</Text>
        </HeaderBand>
        <View style={styles.body}>
          <SurfaceCard>
            <View style={styles.syncRow}>
              <View style={styles.syncText}>
                <Text style={styles.cardTitle}>Brightspace Integration</Text>
                <Text style={styles.muted}>Sincroniza cursos y grupos desde Roble</Text>
              </View>
              <PrimaryButton
                label="Sync"
                loading={isLoadingCourses}
                onPress={refreshCourses}
              />
            </View>
          </SurfaceCard>
          {error ? <Text style={styles.error}>{error}</Text> : null}
          <View style={styles.sectionRow}>
            <Text style={styles.sectionTitle}>Enrolled Courses</Text>
            <Text style={styles.muted}>{courses.length} courses</Text>
          </View>
          {isLoadingCourses ? (
            <LoadingState />
          ) : courses.length === 0 ? (
            <EmptyState title="No hay cursos registrados para este estudiante." />
          ) : (
            courses.map((course) => (
              <SurfaceCard key={`${course.course.id}-${course.groupCode}`}>
                <View style={styles.courseTop}>
                  <View style={styles.iconCircle}>
                    <BookOpen color={colors.primary} size={23} />
                  </View>
                  <View style={styles.flex}>
                    <Text style={styles.courseName}>{course.course.name}</Text>
                    <Text style={styles.muted}>{course.course.code}</Text>
                  </View>
                </View>
                <View style={styles.metaRow}>
                  <Users color={colors.muted} size={18} />
                  <Text style={styles.metaText}>{course.groupName}</Text>
                </View>
                <View style={styles.metaRow}>
                  <RefreshCw color={colors.primary} size={18} />
                  <Text style={styles.metaText}>Group code: {course.groupCode}</Text>
                </View>
                <Text style={styles.category}>{course.groupCategoryName}</Text>
              </SurfaceCard>
            ))
          )}
        </View>
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingBottom: 110 },
  body: { padding: 22, gap: 16 },
  title: { color: '#FFFFFF', fontSize: 22, fontWeight: '900' },
  syncRow: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  syncText: { flex: 1 },
  cardTitle: { fontSize: 17, fontWeight: '900', color: '#111827' },
  muted: { color: colors.muted, marginTop: 4 },
  error: { color: colors.danger, lineHeight: 20 },
  sectionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  sectionTitle: { fontSize: 19, fontWeight: '900', color: '#111827' },
  courseTop: { flexDirection: 'row', gap: 14, alignItems: 'center', marginBottom: 16 },
  iconCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.tint,
  },
  flex: { flex: 1 },
  courseName: { fontSize: 17, fontWeight: '900', color: '#111827' },
  metaRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 10 },
  metaText: { color: colors.slate, fontWeight: '700' },
  category: { color: colors.muted, marginTop: 12 },
});
