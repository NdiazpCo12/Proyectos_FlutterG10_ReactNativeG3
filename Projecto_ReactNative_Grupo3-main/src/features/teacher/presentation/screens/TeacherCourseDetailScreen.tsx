import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { TeacherCoursesStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = NativeStackScreenProps<
  TeacherCoursesStackParamList,
  'TeacherCourseDetail'
>;

export function TeacherCourseDetailScreen({ navigation, route }: Props) {
  const { courseId } = route.params;
  const { courses, assessments } = useTeacherData();

  const course = courses.find((item) => item.id === courseId);
  const relatedAssessments = assessments.filter(
    (item) => item.assessment.courseId === courseId,
  );

  if (!course) {
    return (
      <Screen>
        <HeaderBand>
          <Text style={styles.headerTitle}>Curso</Text>
        </HeaderBand>
        <View style={styles.centered}>
          <Text style={styles.empty}>No encontramos este curso.</Text>
        </View>
      </Screen>
    );
  }

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.headerEyebrow}>{course.code}</Text>
          <Text style={styles.headerTitle}>{course.name}</Text>
          <Text style={styles.headerSubtitle}>Resumen del curso docente</Text>
        </HeaderBand>

        <View style={styles.content}>
          <SurfaceCard>
            <View style={styles.metricRow}>
              <Metric label="Estudiantes" value={String(course.studentCount)} />
              <Metric
                label="Evaluaciones"
                value={String(relatedAssessments.length)}
              />
            </View>
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Estado</Text>
            <Text style={styles.bodyText}>
              {course.status === 'Active'
                ? 'Curso activo para el flujo docente.'
                : `Estado actual: ${course.status}`}
            </Text>
            <Text style={styles.bodyText}>
              Docente responsable: {course.teacherEmail || 'Sin correo'}
            </Text>
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Importación CSV</Text>
              <Text style={styles.bodyText}>
                Podés actualizar la categoría y la matrícula de este curso usando un CSV exportado desde Brightspace.
              </Text>
              <View style={styles.buttonWrap}>
                <PrimaryButton
                  label="Actualizar con CSV"
                  onPress={() => navigation.navigate('CsvImportPreview', { courseId })}
                />
              </View>
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Evaluaciones asociadas</Text>
            {relatedAssessments.length === 0 ? (
              <Text style={styles.empty}>Todavía no hay evaluaciones para este curso.</Text>
            ) : (
              relatedAssessments.map((item) => (
                <View key={item.assessment.id ?? item.assessment.name} style={styles.listRow}>
                  <Text style={styles.listTitle}>{item.assessment.name}</Text>
                  <Text style={styles.listMeta}>
                    {item.submissionCount} entregas · {item.groupCount} grupos
                  </Text>
                </View>
              ))
            )}
          </SurfaceCard>
        </View>
      </ScrollView>
    </Screen>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.metricCard}>
      <Text style={styles.metricValue}>{value}</Text>
      <Text style={styles.metricLabel}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingBottom: spacing.xl },
  headerEyebrow: {
    color: '#DDE9DE',
    fontSize: 13,
    fontWeight: '700',
  },
  headerTitle: {
    color: '#FFFFFF',
    fontSize: 24,
    fontWeight: '900',
    marginTop: 4,
  },
  headerSubtitle: {
    color: '#DDE9DE',
    marginTop: 6,
  },
  content: {
    padding: spacing.lg,
    gap: spacing.md,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
  },
  empty: {
    color: colors.muted,
    fontSize: 15,
  },
  metricRow: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  metricCard: {
    flex: 1,
    backgroundColor: colors.tint,
    borderRadius: 14,
    padding: spacing.md,
  },
  metricValue: {
    color: colors.primary,
    fontSize: 24,
    fontWeight: '900',
  },
  metricLabel: {
    color: colors.muted,
    marginTop: 4,
    fontWeight: '700',
  },
  sectionTitle: {
    color: '#111827',
    fontSize: 17,
    fontWeight: '900',
    marginBottom: spacing.sm,
  },
  bodyText: {
    color: colors.slate,
    lineHeight: 21,
    marginTop: 2,
  },
  buttonWrap: {
    marginTop: spacing.md,
  },
  listRow: {
    paddingVertical: spacing.sm,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
  },
  listTitle: {
    color: '#111827',
    fontWeight: '800',
  },
  listMeta: {
    color: colors.muted,
    marginTop: 4,
  },
});
