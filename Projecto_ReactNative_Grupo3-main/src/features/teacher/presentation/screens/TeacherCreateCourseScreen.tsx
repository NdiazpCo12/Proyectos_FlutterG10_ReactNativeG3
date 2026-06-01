import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useState } from 'react';
import {
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
import { TeacherCoursesStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { userMessage } from '../../../../utils/format';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = NativeStackScreenProps<
  TeacherCoursesStackParamList,
  'TeacherCreateCourse'
>;

export function TeacherCreateCourseScreen({ navigation }: Props) {
  const { createOrResolveCourse } = useTeacherData();
  const [courseName, setCourseName] = useState('');
  const [courseCode, setCourseCode] = useState('');
  const [error, setError] = useState<string>();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validate = () => {
    if (!courseName.trim()) {
      setError('Ingresá el nombre del curso.');
      return false;
    }

    setError(undefined);
    return true;
  };

  const submit = async () => {
    if (!validate()) return;

    setIsSubmitting(true);
    try {
      const result = await createOrResolveCourse(courseName, courseCode);
      Alert.alert(
        result.created ? 'Curso creado' : 'Curso reutilizado',
        result.created
          ? 'El curso quedó listo y te llevamos al detalle.'
          : 'Ya existía un curso con esos datos para este docente, así que reutilizamos ese registro.',
      );
      navigation.replace('TeacherCourseDetail', { courseId: result.id });
    } catch (err) {
      setError(userMessage(err, 'No se pudo crear el curso.'));
    } finally {
      setIsSubmitting(false);
    }
  };

  const continueToCsvImport = () => {
    if (!validate()) return;

    navigation.navigate('CsvImportPreview', {
      initialCourseName: courseName.trim(),
      initialCourseCode: courseCode.trim(),
    });
  };

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.back} onPress={() => navigation.goBack()}>
            {'< Atrás'}
          </Text>
          <Text style={styles.headerTitle}>Crear curso</Text>
          <Text style={styles.headerSubtitle}>
            Creá un curso nuevo o reutilizá uno existente del mismo docente.
          </Text>
        </HeaderBand>

        <View style={styles.content}>
          <SurfaceCard>
            <Text style={styles.sectionTitle}>Datos del curso</Text>
            <TextInput
              placeholder="Ej. Arquitectura de Software"
              placeholderTextColor={colors.muted}
              value={courseName}
              onChangeText={setCourseName}
              style={styles.input}
            />

            <Text style={styles.fieldLabel}>Código (opcional)</Text>
            <TextInput
              placeholder="Ej. ARQ-2026"
              placeholderTextColor={colors.muted}
              autoCapitalize="characters"
              value={courseCode}
              onChangeText={setCourseCode}
              style={styles.input}
            />

            <Text style={styles.helperText}>
              Si ya existe un curso con el mismo nombre para este docente, la app lo reutiliza y evita duplicados.
            </Text>
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Siguientes pasos</Text>
            <Text style={styles.helperText}>
              Podés crear el curso ahora o seguir al flujo de CSV para crearlo o reutilizarlo justo antes de importar.
            </Text>
            <View style={styles.buttonStack}>
              <PrimaryButton
                label="Crear curso"
                loading={isSubmitting}
                onPress={submit}
              />
              <Pressable onPress={continueToCsvImport}>
                <Text style={styles.linkAction}>Continuar con importación CSV</Text>
              </Pressable>
            </View>
          </SurfaceCard>

          {error ? (
            <SurfaceCard>
              <Text style={styles.errorText}>{error}</Text>
            </SurfaceCard>
          ) : null}
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
  helperText: {
    color: colors.slate,
    lineHeight: 21,
    marginTop: spacing.md,
  },
  buttonStack: {
    marginTop: spacing.md,
    gap: spacing.md,
  },
  linkAction: {
    color: colors.primary,
    fontWeight: '800',
    textAlign: 'center',
  },
  errorText: {
    color: colors.danger,
    lineHeight: 21,
  },
});
