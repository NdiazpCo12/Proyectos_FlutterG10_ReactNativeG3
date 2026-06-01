import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { ClipboardList } from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { TeacherAssessmentsStackParamList } from '../../../../navigation/types';
import { colors, spacing } from '../../../../theme/theme';
import { useTeacherData } from '../context/TeacherDataContext';

type Props = NativeStackScreenProps<
  TeacherAssessmentsStackParamList,
  'TeacherAssessments'
>;

export function TeacherAssessmentsScreen({ navigation }: Props) {
  const { assessments, isLoadingAssessments } = useTeacherData();

  return (
    <Screen>
      <HeaderBand>
        <Text style={styles.headerTitle}>Evaluaciones</Text>
      </HeaderBand>
      {isLoadingAssessments ? (
        <View style={styles.centered}>
          <Text style={styles.empty}>Cargando...</Text>
        </View>
      ) : (
        <FlatList
          data={assessments}
          keyExtractor={(item) => item.assessment.id ?? item.assessment.name}
          contentContainerStyle={styles.list}
          ListHeaderComponent={
            <View style={styles.headerActions}>
              <PrimaryButton
                label="Crear evaluación"
                onPress={() =>
                  navigation.navigate('TeacherAssessmentBuilder', {
                    mode: 'create',
                  })
                }
              />
            </View>
          }
          ListEmptyComponent={
            <View style={styles.centered}>
              <ClipboardList color={colors.muted} size={40} />
              <Text style={styles.empty}>No hay evaluaciones aún</Text>
            </View>
          }
          renderItem={({ item }) => (
            <Pressable
              disabled={!item.assessment.id}
              onPress={() =>
                item.assessment.id &&
                navigation.navigate('TeacherAssessmentDetail', {
                  assessmentId: item.assessment.id,
                })
              }
            >
              <SurfaceCard>
                <View style={styles.cardRow}>
                  <View style={styles.cardInfo}>
                    <Text style={styles.assessmentName}>
                      {item.assessment.name}
                    </Text>
                    <Text style={styles.assessmentMeta}>
                      {item.courseName} · {item.submissionCount} entregas
                    </Text>
                  </View>
                  <View
                    style={[
                      styles.badge,
                      item.assessment.status === 'draft'
                        ? styles.badgeDraft
                        : styles.badgeActive,
                    ]}
                  >
                    <Text style={styles.badgeText}>
                      {item.assessment.status === 'draft'
                        ? 'Borrador'
                        : item.assessment.status}
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
  list: {
    padding: spacing.lg,
    gap: spacing.md,
  },
  headerActions: {
    marginBottom: spacing.md,
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
  assessmentName: {
    fontSize: 16,
    fontWeight: '800',
    color: '#111827',
  },
  assessmentMeta: {
    fontSize: 13,
    color: colors.muted,
    marginTop: 3,
  },
  badge: {
    borderRadius: 10,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  badgeDraft: { backgroundColor: colors.tint },
  badgeActive: { backgroundColor: colors.primarySoft },
  badgeText: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.primary,
  },
});
