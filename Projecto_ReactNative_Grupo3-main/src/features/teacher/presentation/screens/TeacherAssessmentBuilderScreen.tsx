import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { TeacherAssessmentsStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { userMessage } from '../../../../utils/format';
import { teacherRepository } from '../../data/repositories/teacherRepositoryImpl';
import { TeacherCourseCategory } from '../../domain/entities/teacherModels';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = NativeStackScreenProps<
  TeacherAssessmentsStackParamList,
  'TeacherAssessmentBuilder'
>;

export function TeacherAssessmentBuilderScreen({ navigation, route }: Props) {
  const { mode } = route.params;
  const editingAssessmentId = mode === 'edit' ? route.params.assessmentId : undefined;
  const { courses, assessments, refreshAssessments } = useTeacherData();
  const editingOverview =
    mode === 'edit'
      ? assessments.find((item) => item.assessment.id === editingAssessmentId)
      : undefined;

  const [name, setName] = useState(editingOverview?.assessment.name ?? '');
  const [courseId, setCourseId] = useState(
    mode === 'create'
      ? route.params.courseId ?? courses[0]?.id ?? ''
      : editingOverview?.assessment.courseId ?? '',
  );
  const [categoryId, setCategoryId] = useState(editingOverview?.assessment.categoryId ?? '');
  const [visibility, setVisibility] = useState(
    editingOverview?.assessment.visibility ?? 'public',
  );
  const [durationDays, setDurationDays] = useState(() => {
    if (!editingOverview) return '7';
    const diff = Math.max(
      1,
      Math.ceil(
        (editingOverview.assessment.endsAt.getTime() - editingOverview.assessment.startsAt.getTime()) /
          86400000,
      ),
    );
    return String(diff);
  });
  const [categories, setCategories] = useState<TeacherCourseCategory[]>([]);
  const [isLoadingCategories, setIsLoadingCategories] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string>();

  const selectedCourse = useMemo(
    () => courses.find((item) => item.id === courseId),
    [courseId, courses],
  );

  useEffect(() => {
    let mounted = true;

    const loadCategories = async () => {
      if (!courseId || mode === 'edit') return;
      setIsLoadingCategories(true);
      try {
        const nextCategories = await teacherRepository.getCourseCategories(courseId);
        if (!mounted) return;
        setCategories(nextCategories);
        setCategoryId((current) =>
          nextCategories.some((item) => item.id === current)
            ? current
            : nextCategories[0]?.id ?? '',
        );
      } catch (err) {
        if (mounted) {
          setError(userMessage(err, 'No se pudieron cargar las categorías del curso.'));
        }
      } finally {
        if (mounted) setIsLoadingCategories(false);
      }
    };

    loadCategories();
    return () => {
      mounted = false;
    };
  }, [courseId, mode]);

  const submit = async () => {
    const trimmedName = name.trim();
    const parsedDuration = Number(durationDays);
    if (!trimmedName) {
      setError('Ingresá un nombre para la evaluación.');
      return;
    }
    if (!Number.isFinite(parsedDuration) || parsedDuration < 1 || parsedDuration > 30) {
      setError('La duración debe estar entre 1 y 30 días.');
      return;
    }
    if (mode === 'create' && (!courseId || !categoryId)) {
      setError('Seleccioná curso y categoría antes de continuar.');
      return;
    }
    if (mode === 'edit' && !editingOverview?.assessment.id) {
      setError('No encontramos la evaluación a editar.');
      return;
    }

    setIsSubmitting(true);
    try {
      if (mode === 'create') {
        const startsAt = new Date();
        const endsAt = new Date(startsAt.getTime() + parsedDuration * 86400000);
        const assessmentId = await teacherRepository.createAssessment({
          courseId,
          categoryId,
          name: trimmedName,
          visibility,
          startsAt,
          endsAt,
        });
        await refreshAssessments();
        navigation.replace('TeacherAssessmentDetail', { assessmentId });
        return;
      }

      const startsAt = editingOverview!.assessment.startsAt;
      const endsAt = new Date(startsAt.getTime() + parsedDuration * 86400000);
      await teacherRepository.updateAssessment({
        assessmentId: editingOverview!.assessment.id!,
        name: trimmedName,
        visibility,
        status: editingOverview!.assessment.status,
        startsAt,
        endsAt,
      });
      await refreshAssessments();
      navigation.replace('TeacherAssessmentDetail', {
        assessmentId: editingOverview!.assessment.id!,
      });
    } catch (err) {
      setError(userMessage(err, 'No se pudo guardar la evaluación.'));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.back} onPress={() => navigation.goBack()}>
            {'< Atrás'}
          </Text>
          <Text style={styles.headerTitle}>
            {mode === 'create' ? 'Crear evaluación' : 'Editar evaluación'}
          </Text>
          <Text style={styles.headerSubtitle}>
            {mode === 'create'
              ? 'Configurá el contexto y la rúbrica predeterminada.'
              : 'Actualizá nombre, visibilidad y ventana de tiempo.'}
          </Text>
        </HeaderBand>

        <View style={styles.content}>
          <SurfaceCard>
            <Text style={styles.sectionTitle}>Nombre</Text>
            <TextInput
              placeholder="Ej. Sprint 1 Team Review"
              placeholderTextColor={colors.muted}
              value={name}
              onChangeText={setName}
              style={styles.input}
            />

            <Text style={styles.fieldLabel}>Visibilidad</Text>
            <View style={styles.chipRow}>
              {['public', 'private'].map((option) => {
                const selected = visibility === option;
                return (
                  <Pressable
                    key={option}
                    onPress={() => setVisibility(option)}
                    style={[styles.chip, selected && styles.chipSelected]}
                  >
                    <Text style={[styles.chipLabel, selected && styles.chipLabelSelected]}>
                      {option === 'public' ? 'Pública' : 'Privada'}
                    </Text>
                  </Pressable>
                );
              })}
            </View>

            <Text style={styles.fieldLabel}>Duración (días)</Text>
            <TextInput
              keyboardType="number-pad"
              value={durationDays}
              onChangeText={setDurationDays}
              style={styles.input}
            />
          </SurfaceCard>

          {mode === 'create' ? (
            <SurfaceCard>
              <Text style={styles.sectionTitle}>Curso</Text>
              <View style={styles.chipRow}>
                {courses.map((course) => {
                  const selected = course.id === courseId;
                  return (
                    <Pressable
                      key={course.id}
                      onPress={() => setCourseId(course.id)}
                      style={[styles.chip, selected && styles.chipSelected]}
                    >
                      <Text style={[styles.chipLabel, selected && styles.chipLabelSelected]}>
                        {course.name}
                      </Text>
                    </Pressable>
                  );
                })}
              </View>

              <Text style={styles.fieldLabel}>Categoría</Text>
              {isLoadingCategories ? (
                <ActivityIndicator color={colors.primary} />
              ) : categories.length === 0 ? (
                <Text style={styles.helperText}>
                  El curso seleccionado no tiene categorías importadas todavía.
                </Text>
              ) : (
                <View style={styles.chipRow}>
                  {categories.map((category) => {
                    const selected = category.id === categoryId;
                    return (
                      <Pressable
                        key={category.id}
                        onPress={() => setCategoryId(category.id)}
                        style={[styles.chip, selected && styles.chipSelected]}
                      >
                        <Text style={[styles.chipLabel, selected && styles.chipLabelSelected]}>
                          {category.name}
                        </Text>
                      </Pressable>
                    );
                  })}
                </View>
              )}
            </SurfaceCard>
          ) : (
            <SurfaceCard>
              <Text style={styles.sectionTitle}>Contexto actual</Text>
              <Text style={styles.helperText}>
                Curso: {editingOverview?.courseName ?? selectedCourse?.name ?? 'Sin curso'}
              </Text>
              <Text style={styles.helperText}>
                Código: {editingOverview?.courseCode ?? selectedCourse?.code ?? 'Sin código'}
              </Text>
            </SurfaceCard>
          )}

          {error ? (
            <SurfaceCard>
              <Text style={styles.errorText}>{error}</Text>
            </SurfaceCard>
          ) : null}

          <PrimaryButton
            label={mode === 'create' ? 'Crear evaluación' : 'Guardar cambios'}
            loading={isSubmitting}
            onPress={submit}
          />
        </View>
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingBottom: spacing.xl },
  back: { color: '#FFFFFF', fontSize: 16, fontWeight: '800', marginBottom: spacing.sm },
  headerTitle: { color: '#FFFFFF', fontSize: 24, fontWeight: '900' },
  headerSubtitle: { color: '#DDE9DE', marginTop: 6 },
  content: { padding: spacing.lg, gap: spacing.md },
  sectionTitle: {
    color: '#111827',
    fontSize: 17,
    fontWeight: '900',
    marginBottom: spacing.sm,
  },
  fieldLabel: {
    color: '#111827',
    fontWeight: '800',
    marginTop: spacing.md,
    marginBottom: spacing.sm,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: '#111827',
    fontSize: 16,
  },
  chipRow: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  chip: {
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: colors.tint,
  },
  chipSelected: { backgroundColor: colors.primary },
  chipLabel: { color: colors.slate, fontWeight: '700' },
  chipLabelSelected: { color: '#FFFFFF' },
  helperText: { color: colors.muted, lineHeight: 21 },
  errorText: { color: colors.danger, lineHeight: 21 },
});
