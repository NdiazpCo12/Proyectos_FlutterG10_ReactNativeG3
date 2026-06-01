import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { BarChart3 } from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { SurfaceCard } from '../../../../components/ui';
import { TeacherReportsStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { teacherRepository } from '../../data/repositories/teacherRepositoryImpl';
import { TeacherAssessmentAnalytics } from '../../domain/entities/teacherModels';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = NativeStackScreenProps<TeacherReportsStackParamList, 'TeacherReports'>;

export function TeacherReportsScreen({ navigation }: Props) {
  const { courses, assessments } = useTeacherData();
  const [selectedCourseId, setSelectedCourseId] = useState<string>('');
  const [selectedAssessmentId, setSelectedAssessmentId] = useState<string>('');
  const [analytics, setAnalytics] = useState<TeacherAssessmentAnalytics | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | undefined>();

  useEffect(() => {
    if (!selectedCourseId && courses.length > 0) {
      setSelectedCourseId(courses[0].id);
    }
  }, [courses, selectedCourseId]);

  const courseAssessments = useMemo(
    () =>
      assessments.filter(
        (item) => item.assessment.courseId === selectedCourseId && item.assessment.id,
      ),
    [assessments, selectedCourseId],
  );

  useEffect(() => {
    if (courseAssessments.length === 0) {
      setSelectedAssessmentId('');
      setAnalytics(null);
      return;
    }

    if (
      !selectedAssessmentId ||
      !courseAssessments.some((item) => item.assessment.id === selectedAssessmentId)
    ) {
      setSelectedAssessmentId(courseAssessments[0].assessment.id ?? '');
    }
  }, [courseAssessments, selectedAssessmentId]);

  useEffect(() => {
    let mounted = true;

    const loadAnalytics = async () => {
      if (!selectedAssessmentId) {
        setAnalytics(null);
        return;
      }

      setIsLoading(true);
      try {
        const nextAnalytics = await teacherRepository.getAssessmentAnalytics(
          selectedAssessmentId,
        );
        if (!mounted) return;
        setAnalytics(nextAnalytics);
        setError(undefined);
      } catch (err) {
        if (!mounted) return;
        setAnalytics(null);
        setError(
          err instanceof Error ? err.message : 'No se pudieron cargar los reportes.',
        );
      } finally {
        if (mounted) setIsLoading(false);
      }
    };

    loadAnalytics();
    return () => {
      mounted = false;
    };
  }, [selectedAssessmentId]);

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.headerTitle}>Reportes</Text>
          <Text style={styles.headerSubtitle}>
            Elegí un curso y una evaluación para revisar el avance del grupo.
          </Text>
        </HeaderBand>

        <View style={styles.content}>
          <SurfaceCard>
            <Text style={styles.sectionTitle}>Curso</Text>
            <ChipRow
              items={courses.map((course) => ({
                id: course.id,
                label: course.name,
              }))}
              selectedId={selectedCourseId}
              onSelect={(id) => {
                setSelectedCourseId(id);
                setSelectedAssessmentId('');
              }}
              emptyLabel="No hay cursos cargados todavía."
            />
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Evaluación</Text>
            <ChipRow
              items={courseAssessments.map((item) => ({
                id: item.assessment.id ?? item.assessment.name,
                label: item.assessment.name,
              }))}
              selectedId={selectedAssessmentId}
              onSelect={setSelectedAssessmentId}
              emptyLabel="Este curso todavía no tiene evaluaciones."
            />
          </SurfaceCard>

          {isLoading ? (
            <View style={styles.loadingWrap}>
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : error ? (
            <SurfaceCard>
              <Text style={styles.errorText}>{error}</Text>
            </SurfaceCard>
          ) : analytics ? (
            <>
              <SurfaceCard>
                <View style={styles.summaryRow}>
                  <SummaryMetric
                    label="Grupos"
                    value={String(analytics.totalGroups)}
                  />
                  <SummaryMetric
                    label="Estudiantes"
                    value={String(analytics.totalStudents)}
                  />
                  <SummaryMetric
                    label="Entregas"
                    value={String(analytics.completedSubmissions)}
                  />
                </View>
              </SurfaceCard>

              <SurfaceCard>
                <View style={styles.sectionHeaderRow}>
                  <Text style={styles.sectionTitle}>Detalle por grupo</Text>
                  <Pressable
                    onPress={() =>
                      navigation.navigate('TeacherAssessmentDetail', {
                        assessmentId: analytics.assessmentId,
                      })
                    }
                  >
                    <Text style={styles.linkText}>Abrir detalle</Text>
                  </Pressable>
                </View>
                {analytics.groupBreakdown.length === 0 ? (
                  <View style={styles.emptyBox}>
                    <BarChart3 color={colors.muted} size={40} />
                    <Text style={styles.emptyText}>No hay datos para este contexto.</Text>
                  </View>
                ) : (
                  analytics.groupBreakdown.map((group) => (
                    <View key={group.groupId} style={styles.groupCard}>
                      <Text style={styles.groupTitle}>{group.groupName}</Text>
                      <Text style={styles.groupMeta}>
                        {group.studentCount} estudiantes · {group.completedCount} entregas completas
                      </Text>
                      <Text style={styles.groupScore}>
                        Promedio: {group.averageScore.toFixed(1)}
                      </Text>
                      {group.students.length > 0 && (
                        <View style={styles.studentList}>
                          {group.students.map((student) => (
                            <View key={student.studentId} style={styles.studentRow}>
                              <View style={styles.studentInfo}>
                                <Text style={styles.studentName}>{student.name}</Text>
                                <Text style={styles.studentEmail}>{student.email || 'Sin correo'}</Text>
                              </View>
                              <Text style={styles.studentScore}>
                                {student.averageScore.toFixed(1)}
                              </Text>
                            </View>
                          ))}
                        </View>
                      )}
                    </View>
                  ))
                )}
              </SurfaceCard>
            </>
          ) : (
            <SurfaceCard>
              <View style={styles.emptyBox}>
                <BarChart3 color={colors.muted} size={40} />
                <Text style={styles.emptyText}>
                  Seleccioná un curso y una evaluación para ver los reportes.
                </Text>
              </View>
            </SurfaceCard>
          )}
        </View>
      </ScrollView>
    </Screen>
  );
}

function ChipRow({
  items,
  selectedId,
  onSelect,
  emptyLabel,
}: {
  items: { id: string; label: string }[];
  selectedId: string;
  onSelect: (id: string) => void;
  emptyLabel: string;
}) {
  if (items.length === 0) {
    return <Text style={styles.emptyInline}>{emptyLabel}</Text>;
  }

  return (
    <View style={styles.chipRow}>
      {items.map((item) => {
        const selected = item.id === selectedId;
        return (
          <Pressable
            key={item.id}
            onPress={() => onSelect(item.id)}
            style={[styles.chip, selected && styles.chipSelected]}
          >
            <Text style={[styles.chipLabel, selected && styles.chipLabelSelected]}>
              {item.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

function SummaryMetric({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.summaryMetric}>
      <Text style={styles.summaryValue}>{value}</Text>
      <Text style={styles.summaryLabel}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingBottom: spacing.xl },
  headerTitle: {
    color: '#FFFFFF',
    fontSize: 24,
    fontWeight: '900',
  },
  headerSubtitle: {
    color: '#DDE9DE',
    marginTop: 6,
  },
  content: {
    padding: spacing.lg,
    gap: spacing.md,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: spacing.md,
  },
  sectionTitle: {
    color: '#111827',
    fontSize: 17,
    fontWeight: '900',
    marginBottom: spacing.sm,
  },
  linkText: {
    color: colors.primary,
    fontWeight: '800',
  },
  chipRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  chip: {
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: colors.tint,
  },
  chipSelected: {
    backgroundColor: colors.primary,
  },
  chipLabel: {
    color: colors.slate,
    fontWeight: '700',
  },
  chipLabelSelected: {
    color: '#FFFFFF',
  },
  emptyInline: {
    color: colors.muted,
  },
  loadingWrap: {
    paddingVertical: spacing.xl,
    alignItems: 'center',
  },
  errorText: {
    color: colors.danger,
    lineHeight: 21,
  },
  summaryRow: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  summaryMetric: {
    flex: 1,
    backgroundColor: colors.tint,
    borderRadius: 14,
    padding: spacing.md,
  },
  summaryValue: {
    color: colors.primary,
    fontSize: 24,
    fontWeight: '900',
  },
  summaryLabel: {
    color: colors.muted,
    marginTop: 4,
    fontWeight: '700',
  },
  emptyBox: {
    paddingVertical: spacing.xl,
    alignItems: 'center',
    gap: spacing.sm,
  },
  emptyText: {
    color: colors.muted,
    textAlign: 'center',
  },
  groupCard: {
    marginTop: spacing.md,
    paddingTop: spacing.md,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
  },
  groupTitle: {
    color: '#111827',
    fontSize: 16,
    fontWeight: '800',
  },
  groupMeta: {
    color: colors.muted,
    marginTop: 4,
  },
  groupScore: {
    color: colors.primary,
    marginTop: 6,
    fontWeight: '800',
  },
  studentList: {
    marginTop: spacing.md,
    gap: spacing.sm,
  },
  studentRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.md,
    backgroundColor: colors.tint,
    borderRadius: 14,
    padding: spacing.md,
  },
  studentInfo: {
    flex: 1,
  },
  studentName: {
    color: '#111827',
    fontWeight: '800',
  },
  studentEmail: {
    color: colors.muted,
    marginTop: 2,
    fontSize: 12,
  },
  studentScore: {
    color: colors.primary,
    fontWeight: '900',
    fontSize: 16,
  },
});
