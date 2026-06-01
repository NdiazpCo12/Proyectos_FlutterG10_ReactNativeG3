import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useMemo, useState } from 'react';
import {
  Alert,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { AssessmentStackParamList } from '../../../../navigation/types';
import { colors } from '../../../../theme/theme';
import { userMessage } from '../../../../utils/format';
import { useStudentData } from '../context/StudentDataContext';

type Props = NativeStackScreenProps<
  AssessmentStackParamList,
  'AssessmentDetail'
>;

export function AssessmentDetailScreen({ navigation, route }: Props) {
  const { assessments, submitAssessment } = useStudentData();
  const assessment = assessments.find(
    (item) =>
      item.assessment.id === route.params.assessmentId &&
      item.group.id === route.params.groupId,
  );
  const [teammateIndex, setTeammateIndex] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [ratings, setRatings] = useState<Record<string, Record<string, number>>>(
    () =>
      assessment
        ? Object.fromEntries(
            assessment.teammates.map((teammate) => [
              teammate.studentId,
              { ...(assessment.savedScoresByReviewee[teammate.studentId] ?? {}) },
            ]),
          )
        : {},
  );

  const teammate = assessment?.teammates[teammateIndex];
  const isLast = assessment
    ? teammateIndex === assessment.teammates.length - 1
    : false;

  const progressLabel = useMemo(() => {
    if (!assessment) return '';
    return `Compañero ${teammateIndex + 1} de ${assessment.teammates.length}`;
  }, [assessment, teammateIndex]);

  if (!assessment || !teammate) {
    return (
      <Screen>
        <HeaderBand>
          <Text style={styles.title}>Evaluación</Text>
        </HeaderBand>
        <View style={styles.body}>
          <Text style={styles.muted}>
            No fue posible abrir esta evaluación.
          </Text>
          <PrimaryButton label="Volver" onPress={() => navigation.goBack()} />
        </View>
      </Screen>
    );
  }

  const validateCurrent = () =>
    assessment.criteria.every((criterion) => {
      const criterionId = criterion.criterion.id ?? '';
      return Boolean(ratings[teammate.studentId]?.[criterionId]);
    });

  const setRating = (criterionId: string, value: number) => {
    setRatings((current) => ({
      ...current,
      [teammate.studentId]: {
        ...(current[teammate.studentId] ?? {}),
        [criterionId]: value,
      },
    }));
  };

  const goNext = async () => {
    if (!validateCurrent()) {
      Alert.alert(
        'Evaluación incompleta',
        'Completa todos los criterios antes de continuar.',
      );
      return;
    }
    if (!isLast) {
      setTeammateIndex((value) => value + 1);
      return;
    }

    Alert.alert(
      'Enviar evaluación',
      `Se enviarán las calificaciones de ${assessment.teammates.length} compañeros.`,
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Enviar',
          onPress: async () => {
            setIsSubmitting(true);
            try {
              await submitAssessment(assessment, ratings);
              Alert.alert('Listo', 'Evaluación enviada correctamente.');
              navigation.goBack();
            } catch (err) {
              Alert.alert(
                'Error',
                userMessage(err, 'No se pudo enviar la evaluación.'),
              );
            } finally {
              setIsSubmitting(false);
            }
          },
        },
      ],
    );
  };

  return (
    <Screen>
      <HeaderBand>
        <TouchableOpacity
          disabled={isSubmitting}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.back}>{'< Atrás'}</Text>
        </TouchableOpacity>
        <Text style={styles.title}>{assessment.assessment.name}</Text>
        <Text style={styles.subtitle}>
          {assessment.course.code} - {assessment.course.name}
        </Text>
        <Text style={styles.subtitle}>
          {assessment.categoryName} - {assessment.group.groupName}
        </Text>
      </HeaderBand>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text style={styles.progress}>{progressLabel}</Text>
        <SurfaceCard>
          <Text style={styles.person}>{teammate.name}</Text>
          <Text style={styles.muted}>{teammate.email}</Text>
          {assessment.criteria.map((criterion) => {
            const criterionId = criterion.criterion.id ?? '';
            const selected = ratings[teammate.studentId]?.[criterionId];
            const selectedLevel = criterion.levels.find(
              (level) => level.scoreValue === selected,
            );
            return (
              <View key={criterionId} style={styles.criterion}>
                <Text style={styles.criterionTitle}>
                  {criterion.criterion.name}
                </Text>
                {criterion.criterion.description ? (
                  <Text style={styles.muted}>
                    {criterion.criterion.description}
                  </Text>
                ) : null}
                <Text style={styles.levelText}>
                  {selectedLevel
                    ? `${selectedLevel.label}: ${
                        selectedLevel.descriptionEs ||
                        selectedLevel.descriptionEn
                      }`
                    : 'Selecciona un puntaje'}
                </Text>
                <View style={styles.levels}>
                  {criterion.levels.map((level) => (
                    <TouchableOpacity
                      key={`${criterionId}-${level.scoreValue}`}
                      disabled={isSubmitting}
                      onPress={() => setRating(criterionId, level.scoreValue)}
                      style={[
                        styles.levelButton,
                        selected === level.scoreValue &&
                          styles.levelButtonSelected,
                      ]}
                    >
                      <Text
                        style={[
                          styles.levelButtonText,
                          selected === level.scoreValue &&
                            styles.levelButtonTextSelected,
                        ]}
                      >
                        {level.scoreValue}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>
            );
          })}
        </SurfaceCard>
      </ScrollView>
      <View style={styles.footer}>
        <PrimaryButton
          label="Anterior"
          disabled={teammateIndex === 0 || isSubmitting}
          onPress={() => setTeammateIndex((value) => value - 1)}
        />
        <View style={styles.footerSpacer} />
        <PrimaryButton
          label={isLast ? 'Enviar evaluación' : 'Siguiente'}
          loading={isSubmitting}
          onPress={goNext}
        />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  scroll: { padding: 22, paddingBottom: 120 },
  body: { padding: 22, gap: 16 },
  back: { color: '#FFFFFF', fontSize: 16, fontWeight: '800', marginBottom: 14 },
  title: { color: '#FFFFFF', fontSize: 21, fontWeight: '900' },
  subtitle: { color: '#DDE9DE', marginTop: 6 },
  progress: { color: colors.slate, fontWeight: '900', marginBottom: 14 },
  person: { color: '#111827', fontSize: 19, fontWeight: '900' },
  muted: { color: colors.muted, marginTop: 6, lineHeight: 20 },
  criterion: {
    paddingVertical: 18,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  criterionTitle: { color: '#111827', fontSize: 16, fontWeight: '900' },
  levelText: { color: colors.muted, marginTop: 10, lineHeight: 20 },
  levels: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginTop: 14 },
  levelButton: {
    width: 44,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.surface,
  },
  levelButtonSelected: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  levelButtonText: { color: colors.slate, fontWeight: '900' },
  levelButtonTextSelected: { color: '#FFFFFF' },
  footer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: colors.background,
    borderTopColor: colors.border,
    borderTopWidth: 1,
    padding: 16,
    flexDirection: 'row',
  },
  footerSpacer: { width: 12 },
});
