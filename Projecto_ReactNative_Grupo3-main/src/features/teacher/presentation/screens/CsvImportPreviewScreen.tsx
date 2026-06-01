import * as DocumentPicker from 'expo-document-picker';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useMemo, useState } from 'react';
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
import { TeacherCoursesStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { userMessage } from '../../../../utils/format';
import { teacherRepository } from '../../data/repositories/teacherRepositoryImpl';
import { useAuth } from '../../../auth/presentation/context/AuthContext';
import { useTeacherData } from '../context/TeacherDataContext';
import { parseTeacherCsvText } from '../utils/csvImport';

type Props = NativeStackScreenProps<TeacherCoursesStackParamList, 'CsvImportPreview'>;

export function CsvImportPreviewScreen({ navigation, route }: Props) {
  const params = route.params ?? {};
  const { courseId } = params;
  const { user } = useAuth();
  const { courses, refreshAll } = useTeacherData();
  const course = courses.find((item) => item.id === courseId);
  const [courseName, setCourseName] = useState(params.initialCourseName ?? '');
  const [courseCode, setCourseCode] = useState(params.initialCourseCode ?? '');
  const [fileName, setFileName] = useState('');
  const [rawCsv, setRawCsv] = useState('');
  const [error, setError] = useState<string>();
  const [isPicking, setIsPicking] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const preview = useMemo(() => parseTeacherCsvText(rawCsv), [rawCsv]);
  const uniqueStudents = useMemo(
    () => new Set(preview.rows.map((row) => row.email).filter(Boolean)).size,
    [preview.rows],
  );
  const uniqueGroups = useMemo(
    () =>
      new Set(
        preview.rows.map((row, index) => row.groupCode || row.groupName || `GRUPO-${index + 1}`),
      ).size,
    [preview.rows],
  );

  const pickDocument = async () => {
    setIsPicking(true);
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ['text/csv', 'text/comma-separated-values', 'application/vnd.ms-excel'],
        copyToCacheDirectory: true,
        multiple: false,
      });
      if (result.canceled || result.assets.length === 0) return;

      const asset = result.assets[0];
      const response = await fetch(asset.uri);
      const text = await response.text();
      setFileName(asset.name);
      setRawCsv(text);
      setError(undefined);
    } catch (err) {
      setError(userMessage(err, 'No se pudo leer el archivo CSV.'));
    } finally {
      setIsPicking(false);
    }
  };

  const submitImport = async () => {
    if (!course && !courseName.trim()) {
      setError('Ingresá el nombre del curso antes de continuar.');
      return;
    }
    if (preview.rows.length === 0) {
      setError('Seleccioná un archivo CSV válido antes de continuar.');
      return;
    }
    if (preview.errors.length > 0) {
      setError(preview.errors[0]);
      return;
    }

    setIsSubmitting(true);
    try {
      const result = await teacherRepository.importCourseCsv({
        courseId: course?.id,
        courseCode: (course?.code ?? courseCode).trim(),
        courseName: (course?.name ?? courseName).trim(),
        teacherEmail: user?.email ?? '',
        groupCategoryName: preview.categoryName,
        rows: preview.rows,
      });

      if (!result.success) {
        throw new Error(result.errors[0] ?? 'No se pudo completar la importación.');
      }

      await refreshAll();
      Alert.alert(
        'Importación completada',
        `Se actualizaron ${result.groupCount} grupos y ${result.studentCount} estudiantes.`,
        [
          {
            text: 'Listo',
            onPress: () => {
              if (result.courseId) {
                navigation.replace('TeacherCourseDetail', {
                  courseId: result.courseId,
                });
                return;
              }
              navigation.goBack();
            },
          },
        ],
      );
    } catch (err) {
      setError(userMessage(err, 'No se pudo completar la importación.'));
    } finally {
      setIsSubmitting(false);
    }
  };

  if (courseId && !course) {
    return (
      <Screen>
        <HeaderBand>
          <Text style={styles.headerTitle}>Importar CSV</Text>
        </HeaderBand>
        <View style={styles.centered}>
          <Text style={styles.empty}>No encontramos el curso seleccionado.</Text>
        </View>
      </Screen>
    );
  }

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.headerEyebrow}>{course?.code ?? 'Nuevo curso'}</Text>
          <Text style={styles.headerTitle}>Preview de importación CSV</Text>
          <Text style={styles.headerSubtitle}>{course?.name ?? 'Creá o reutilizá un curso antes de importar'}</Text>
        </HeaderBand>

        <View style={styles.content}>
          {!course ? (
            <SurfaceCard>
              <Text style={styles.sectionTitle}>Curso destino</Text>
              <TextInput
                placeholder="Nombre del curso"
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

              <Text style={styles.bodyText}>
                Si ya existe un curso del mismo docente con ese nombre o código, lo reutilizamos y evitamos duplicados.
              </Text>
            </SurfaceCard>
          ) : null}

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Archivo</Text>
            <Text style={styles.bodyText}>
              Elegí un CSV exportado desde Brightspace para reemplazar la categoría y los grupos del curso.
            </Text>
            <View style={styles.buttonWrap}>
              <PrimaryButton
                label={isPicking ? 'Leyendo archivo...' : 'Seleccionar CSV'}
                loading={isPicking}
                onPress={pickDocument}
              />
            </View>
            {fileName ? <Text style={styles.fileName}>{fileName}</Text> : null}
          </SurfaceCard>

          <SurfaceCard>
            <Text style={styles.sectionTitle}>Resumen</Text>
            <View style={styles.metricRow}>
              <Metric label="Filas" value={String(preview.rows.length)} />
              <Metric label="Grupos" value={String(uniqueGroups)} />
              <Metric label="Estudiantes" value={String(uniqueStudents)} />
            </View>
            <Text style={styles.bodyText}>
              Categoría detectada: {preview.categoryName || 'Sin categoría'}
            </Text>
            <Text style={styles.warningText}>
              Si la categoría ya existe, la importación reemplaza sus grupos y membresías anteriores.
            </Text>
          </SurfaceCard>

          {preview.rows.length > 0 ? (
            <SurfaceCard>
              <Text style={styles.sectionTitle}>Vista previa</Text>
              {preview.rows.slice(0, 8).map((row, index) => (
                <View key={`${row.email}-${index}`} style={styles.previewRow}>
                  <View style={styles.previewInfo}>
                    <Text style={styles.previewName}>
                      {`${row.firstName} ${row.lastName}`.trim() || row.username || 'Estudiante'}
                    </Text>
                    <Text style={styles.previewMeta}>{row.email || 'Sin correo'}</Text>
                  </View>
                  <View>
                    <Text style={styles.previewGroup}>{row.groupName || row.groupCode}</Text>
                    <Text style={styles.previewMeta}>{row.groupCode || 'Sin código'}</Text>
                  </View>
                </View>
              ))}
              {preview.rows.length > 8 ? (
                <Text style={styles.moreText}>
                  +{preview.rows.length - 8} filas más en el archivo
                </Text>
              ) : null}
            </SurfaceCard>
          ) : null}

          {preview.errors.length > 0 ? (
            <SurfaceCard>
              <Text style={styles.errorTitle}>Validaciones pendientes</Text>
              {preview.errors.map((item) => (
                <Text key={item} style={styles.errorText}>
                  • {item}
                </Text>
              ))}
            </SurfaceCard>
          ) : null}

          {error ? (
            <SurfaceCard>
              <Text style={styles.errorText}>{error}</Text>
            </SurfaceCard>
          ) : null}

          <View style={styles.footerActions}>
            <Pressable onPress={() => navigation.goBack()}>
              <Text style={styles.cancelText}>Cancelar</Text>
            </Pressable>
            <PrimaryButton
              label="Confirmar importación"
              loading={isSubmitting}
              disabled={preview.rows.length === 0 || preview.errors.length > 0}
              onPress={submitImport}
            />
          </View>
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
  headerEyebrow: { color: '#DDE9DE', fontSize: 13, fontWeight: '700' },
  headerTitle: { color: '#FFFFFF', fontSize: 24, fontWeight: '900', marginTop: 4 },
  headerSubtitle: { color: '#DDE9DE', marginTop: 6 },
  content: { padding: spacing.lg, gap: spacing.md },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
  },
  empty: { color: colors.muted, fontSize: 15 },
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
  bodyText: { color: colors.slate, lineHeight: 21 },
  warningText: {
    color: colors.warning,
    lineHeight: 20,
    marginTop: spacing.sm,
    fontWeight: '700',
  },
  buttonWrap: { marginTop: spacing.md },
  fileName: { color: colors.muted, marginTop: spacing.sm },
  metricRow: { flexDirection: 'row', gap: spacing.md, marginBottom: spacing.sm },
  metricCard: {
    flex: 1,
    backgroundColor: colors.tint,
    borderRadius: 14,
    padding: spacing.md,
  },
  metricValue: { color: colors.primary, fontSize: 24, fontWeight: '900' },
  metricLabel: { color: colors.muted, marginTop: 4, fontWeight: '700' },
  previewRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: spacing.md,
    paddingVertical: spacing.sm,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
  },
  previewInfo: { flex: 1 },
  previewName: { color: '#111827', fontWeight: '800' },
  previewMeta: { color: colors.muted, marginTop: 3, fontSize: 12 },
  previewGroup: { color: colors.primary, fontWeight: '800', textAlign: 'right' },
  moreText: { color: colors.muted, marginTop: spacing.sm },
  errorTitle: { color: colors.danger, fontWeight: '900', marginBottom: spacing.sm },
  errorText: { color: colors.danger, lineHeight: 21 },
  footerActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: spacing.md,
  },
  cancelText: { color: colors.muted, fontWeight: '800' },
});
