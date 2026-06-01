import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import {
  EmptyState,
  LoadingState,
  PrimaryButton,
  StatusChip,
  SurfaceCard,
} from '../../../../components/ui';
import { AssessmentStackParamList } from '../../../../navigation/types';
import { colors } from '../../../../theme/theme';
import { formatDate } from '../../../../utils/format';
import { useStudentData } from '../context/StudentDataContext';

type Nav = NativeStackNavigationProp<AssessmentStackParamList, 'Assessments'>;

export function AssessmentsScreen() {
  const navigation = useNavigation<Nav>();
  const { assessments, isLoadingAssessments, refreshAssessments } =
    useStudentData();

  return (
    <Screen>
      <ScrollView
        refreshControl={
          <RefreshControl
            refreshing={isLoadingAssessments}
            onRefresh={refreshAssessments}
          />
        }
        contentContainerStyle={styles.scroll}
      >
        <HeaderBand>
          <Text style={styles.title}>Assessments</Text>
          <Text style={styles.subtitle}>
            Califica a tus compañeros cuando la actividad esté activa.
          </Text>
        </HeaderBand>
        <View style={styles.body}>
          {isLoadingAssessments ? (
            <LoadingState />
          ) : assessments.length === 0 ? (
            <EmptyState title="No tienes evaluaciones disponibles por ahora." />
          ) : (
            assessments.map((item) => (
              <SurfaceCard key={`${item.assessment.id}-${item.group.id}`}>
                <View style={styles.cardHeader}>
                  <StatusChip label={item.statusLabel} />
                  <Text style={styles.chevron}>{'>'}</Text>
                </View>
                <Text style={styles.cardTitle}>{item.assessment.name}</Text>
                <Text style={styles.muted}>
                  {item.course.code} - {item.course.name}
                </Text>
                <Text style={styles.meta}>
                  Disponible hasta {formatDate(item.assessment.endsAt)}
                </Text>
                <Text style={styles.meta}>
                  {item.categoryName} - {item.group.groupName}
                </Text>
                <Text style={styles.helper}>
                  Debes evaluar a {item.teammates.length} compañeros
                </Text>
                <PrimaryButton
                  label={actionLabel(item.statusLabel)}
                  disabled={!item.canSubmit}
                  onPress={() =>
                    navigation.navigate('AssessmentDetail', {
                      assessmentId: item.assessment.id ?? '',
                      groupId: item.group.id,
                    })
                  }
                />
              </SurfaceCard>
            ))
          )}
        </View>
      </ScrollView>
    </Screen>
  );
}

const actionLabel = (status: string) => {
  switch (status) {
    case 'Completed':
      return 'Evaluación enviada';
    case 'Scheduled':
      return 'Disponible pronto';
    case 'Closed':
      return 'Actividad cerrada';
    case 'No teammates':
      return 'Sin compañeros';
    case 'No criteria':
      return 'Sin criterios';
    default:
      return 'Iniciar evaluación';
  }
};

const styles = StyleSheet.create({
  scroll: { paddingBottom: 110 },
  body: { padding: 22, gap: 16 },
  title: { color: '#FFFFFF', fontSize: 22, fontWeight: '900' },
  subtitle: { color: '#DDE9DE', fontSize: 15, marginTop: 6 },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  chevron: { color: colors.slate, fontSize: 32 },
  cardTitle: { color: '#111827', fontSize: 18, fontWeight: '900', marginTop: 18 },
  muted: { color: colors.muted, marginTop: 8 },
  meta: { color: colors.slate, marginTop: 12, fontWeight: '700' },
  helper: { color: colors.slate, marginVertical: 16 },
});
