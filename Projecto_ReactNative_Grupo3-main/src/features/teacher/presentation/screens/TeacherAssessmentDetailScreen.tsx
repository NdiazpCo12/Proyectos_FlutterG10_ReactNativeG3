import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Alert, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useEffect, useState } from 'react';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import {
  TeacherAssessmentsStackParamList,
  TeacherReportsStackParamList,
} from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { userMessage } from '../../../../utils/format';
import { teacherRepository } from '../../data/repositories/teacherRepositoryImpl';
import { TeacherAssessmentDetail } from '../../domain/entities/teacherModels';
import { useTeacherData } from '../context/TeacherDataContext';

type Props =
  | NativeStackScreenProps<
      TeacherAssessmentsStackParamList,
      'TeacherAssessmentDetail'
    >
  | NativeStackScreenProps<
      TeacherReportsStackParamList,
      'TeacherAssessmentDetail'
    >;

export function TeacherAssessmentDetailScreen({ navigation, route }: Props) {
  const { assessmentId } = route.params;
  const { assessments, refreshAssessments } = useTeacherData();
  const [detail, setDetail] = useState<TeacherAssessmentDetail | null>(null);
  const [detailError, setDetailError] = useState<string>();

  const overview = assessments.find((item) => item.assessment.id === assessmentId);

  useEffect(() => {
    let mounted = true;

    const loadDetail = async () => {
      try {
        const nextDetail = await teacherRepository.getAssessmentDetail(assessmentId);
        if (!mounted) return;
        setDetail(nextDetail);
        setDetailError(undefined);
      } catch (err) {
        if (!mounted) return;
        setDetail(null);
        setDetailError(
          userMessage(err, 'No se pudo cargar el detalle completo de la evaluación.'),
        );
      }
    };

    loadDetail();
    return () => {
      mounted = false;
    };
  }, [assessmentId]);

  const removeAssessment = () => {
    if (!overview?.assessment.id) return;
    Alert.alert(
      'Eliminar evaluación',
      'Se eliminarán la evaluación, sus criterios, entregas, peer reviews y puntajes asociados. Esta acción no se puede deshacer.',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Eliminar',
          style: 'destructive',
          onPress: async () => {
              await teacherRepository.deleteAssessment(overview.assessment.id!);
              await refreshAssessments();
              navigation.goBack();
          },
        },
      ],
    );
  };

  const openEdit = () => {
    if (!overview?.assessment.id) return;
    (
      navigation as NativeStackScreenProps<
        TeacherAssessmentsStackParamList,
        'TeacherAssessmentDetail'
      >['navigation']
    ).navigate('TeacherAssessmentBuilder', {
      mode: 'edit',
      assessmentId: overview.assessment.id,
    });
  };

  if (!overview) {
    return (
      <Screen>
        <HeaderBand>
          <Text style={styles.headerTitle}>Evaluación</Text>
        </HeaderBand>
        <View style={styles.centered}>
          <Text style={styles.empty}>No encontramos esta evaluación.</Text>
        </View>
      </Screen>
    );
  }

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.headerEyebrow}>{overview.courseCode}</Text>
          <Text style={styles.headerTitle}>{overview.assessment.name}</Text>
          <Text style={styles.headerSubtitle}>{overview.courseName}</Text>
        </HeaderBand>

        <View style={styles.content}>
          <SurfaceCard>
            <View style={styles.metricRow}>
              <Metric label="Entregas" value={String(overview.submissionCount)} />
              <Metric label="Grupos" value={String(overview.groupCount)} />
            </View>
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Estado</Text>
            <Text style={styles.bodyText}>
              Visibilidad: {overview.assessment.visibility || 'private'}
            </Text>
            <Text style={styles.bodyText}>
              Estado actual: {overview.assessment.status}
            </Text>
            {detail ? (
              <Text style={styles.bodyText}>
                Respuestas enviadas: {detail.responsesSubmitted}/{detail.totalReviewers || overview.submissionCount}
              </Text>
            ) : null}
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Rúbrica</Text>
            {detailError ? (
              <Text style={styles.bodyText}>{detailError}</Text>
            ) : !detail ? (
              <Text style={styles.bodyText}>Cargando criterios...</Text>
            ) : detail.criteria.length === 0 ? (
              <Text style={styles.bodyText}>Esta evaluación todavía no tiene criterios.</Text>
            ) : (
              detail.criteria.map((criterionDetail) => (
                <View
                  key={criterionDetail.criterion.id ?? criterionDetail.criterion.name}
                  style={styles.criteriaCard}
                >
                  <Text style={styles.criteriaTitle}>{criterionDetail.criterion.name}</Text>
                  {criterionDetail.criterion.description ? (
                    <Text style={styles.criteriaDescription}>
                      {criterionDetail.criterion.description}
                    </Text>
                  ) : null}
                  <Text style={styles.criteriaMeta}>
                    Peso: {criterionDetail.criterion.weight}% · Niveles: {criterionDetail.levels.length}
                  </Text>
                </View>
              ))
            )}
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Acciones</Text>
            <Text style={styles.bodyText}>
              Podés ajustar los metadatos de la evaluación o eliminarla con limpieza segura de datos dependientes.
            </Text>
            <View style={styles.buttonWrap}>
              <PrimaryButton label="Editar evaluación" onPress={openEdit} />
            </View>
            <View style={styles.buttonWrap}>
              <PrimaryButton label="Eliminar evaluación" onPress={removeAssessment} />
            </View>
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
  criteriaCard: {
    marginTop: spacing.sm,
    paddingTop: spacing.sm,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
  },
  criteriaTitle: {
    color: '#111827',
    fontWeight: '800',
  },
  criteriaDescription: {
    color: colors.muted,
    marginTop: 4,
    lineHeight: 20,
  },
  criteriaMeta: {
    color: colors.primary,
    marginTop: 6,
    fontWeight: '700',
  },
});
