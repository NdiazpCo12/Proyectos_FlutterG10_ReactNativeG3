import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { GraduationCap } from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton } from '../../../../components/ui';
import { TeacherTabsParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { useAuth } from '../../../auth/presentation/context/AuthContext';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = BottomTabScreenProps<TeacherTabsParamList, 'TeacherHome'>;

export function TeacherHomeScreen({ navigation }: Props) {
  const { user } = useAuth();
  const { courses, assessments, isLoadingCourses, isLoadingAssessments } =
    useTeacherData();

  return (
    <Screen>
      <HeaderBand>
        <View style={styles.headerRow}>
          <GraduationCap color="#FFFFFF" size={28} />
          <View>
            <Text style={styles.greeting}>
              Hola, {user?.name ?? 'Docente'}
            </Text>
            <Text style={styles.subtitle}>Panel del docente</Text>
          </View>
        </View>
      </HeaderBand>
      <ScrollView contentContainerStyle={styles.scroll}>
        <View style={styles.ctaCard}>
          <Text style={styles.ctaTitle}>Crear curso</Text>
          <Text style={styles.ctaBody}>
            Abrí un curso nuevo o reutilizá uno existente antes de importar tu CSV.
          </Text>
          <View style={styles.ctaButtonWrap}>
            <PrimaryButton
              label="Crear curso"
              onPress={() =>
                navigation.navigate('CoursesStack', {
                  screen: 'TeacherCreateCourse',
                })
              }
            />
          </View>
        </View>
        <View style={styles.row}>
          <View style={styles.card}>
            <Text style={styles.cardValue}>
              {isLoadingCourses ? '...' : courses.length}
            </Text>
            <Text style={styles.cardLabel}>Cursos</Text>
          </View>
          <View style={styles.card}>
            <Text style={styles.cardValue}>
              {isLoadingAssessments ? '...' : assessments.length}
            </Text>
            <Text style={styles.cardLabel}>Evaluaciones</Text>
          </View>
        </View>
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  greeting: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '800',
  },
  subtitle: {
    color: '#DDE9DE',
    fontSize: 14,
    marginTop: 2,
  },
  scroll: {
    padding: spacing.lg,
    gap: spacing.lg,
  },
  ctaCard: {
    backgroundColor: colors.surface,
    borderRadius: 16,
    padding: spacing.lg,
  },
  ctaTitle: {
    fontSize: 18,
    fontWeight: '900',
    color: '#111827',
  },
  ctaBody: {
    marginTop: spacing.sm,
    color: colors.slate,
    lineHeight: 21,
  },
  ctaButtonWrap: {
    marginTop: spacing.md,
  },
  row: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  card: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: 14,
    padding: spacing.md,
    alignItems: 'center',
  },
  cardValue: {
    fontSize: 28,
    fontWeight: '900',
    color: colors.primary,
  },
  cardLabel: {
    fontSize: 13,
    color: colors.muted,
    marginTop: 4,
  },
});
