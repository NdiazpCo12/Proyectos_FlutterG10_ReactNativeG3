import { useMemo, useState } from 'react';
import { RefreshControl, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import Svg, { Circle, Line, Polygon, Text as SvgText } from 'react-native-svg';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { EmptyState, LoadingState, SurfaceCard } from '../../../../components/ui';
import { colors } from '../../../../theme/theme';
import { formatDate } from '../../../../utils/format';
import { useStudentData } from '../context/StudentDataContext';

export function ResultsScreen() {
  const { results, isLoadingResults, refreshResults } = useStudentData();
  const [selectedCourseId, setSelectedCourseId] = useState<string | undefined>();
  const selectedCourse = useMemo(() => {
    if (results.courseResults.length === 0) return undefined;
    return (
      results.courseResults.find((course) => course.courseId === selectedCourseId) ??
      results.courseResults[0]
    );
  }, [results.courseResults, selectedCourseId]);

  return (
    <Screen>
      <ScrollView
        refreshControl={
          <RefreshControl refreshing={isLoadingResults} onRefresh={refreshResults} />
        }
        contentContainerStyle={styles.scroll}
      >
        <HeaderBand>
          <Text style={styles.title}>My Results</Text>
          <Text style={styles.subtitle}>View your public peer assessment feedback by course</Text>
        </HeaderBand>
        <View style={styles.body}>
          {isLoadingResults ? (
            <LoadingState />
          ) : results.courseResults.length === 0 ? (
            <EmptyState title="No hay resultados públicos disponibles todavía." />
          ) : (
            <>
              <SurfaceCard>
                <Text style={styles.sectionTitle}>Select Course</Text>
                <View style={styles.coursePills}>
                  {results.courseResults.map((course) => (
                    <TouchableOpacity
                      key={course.courseId}
                      onPress={() => setSelectedCourseId(course.courseId)}
                      style={[
                        styles.coursePill,
                        selectedCourse?.courseId === course.courseId && styles.coursePillActive,
                      ]}
                    >
                      <Text
                        style={[
                          styles.coursePillText,
                          selectedCourse?.courseId === course.courseId && styles.coursePillTextActive,
                        ]}
                      >
                        {course.displayLabel}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </SurfaceCard>
              <SurfaceCard>
                <Text style={styles.sectionTitle}>Overall Performance</Text>
                <Text style={styles.muted}>{selectedCourse?.displayLabel}</Text>
                <Text style={styles.score}>{(selectedCourse?.overallScore ?? 0).toFixed(1)}</Text>
                <Text style={styles.centerMuted}>Out of 5.0</Text>
                <View style={styles.statsRow}>
                  <Stat value={selectedCourse?.assessmentCount ?? 0} label="Assessments" />
                  <Stat value={selectedCourse?.reviewCount ?? 0} label="Reviews" />
                </View>
              </SurfaceCard>
              <SurfaceCard>
                <Text style={styles.sectionTitle}>Criteria Breakdown</Text>
                {selectedCourse?.criteria.length ? (
                  <RadarChart scores={selectedCourse.criteria.slice(0, 8)} />
                ) : (
                  <Text style={styles.muted}>No criteria data available for this course yet.</Text>
                )}
              </SurfaceCard>
              <SurfaceCard>
                <Text style={styles.sectionTitle}>Detailed Scores</Text>
                {selectedCourse?.criteria.length ? (
                  selectedCourse.criteria.map((criterion) => (
                    <View key={criterion.label} style={styles.barRow}>
                      <Text style={styles.barLabel}>{criterion.label}</Text>
                      <View style={styles.barTrack}>
                        <View style={[styles.barFill, { width: `${Math.min(100, (criterion.score / 5) * 100)}%` }]} />
                      </View>
                      <Text style={styles.barValue}>{criterion.score.toFixed(1)}</Text>
                    </View>
                  ))
                ) : (
                  <Text style={styles.muted}>No detailed scores available yet.</Text>
                )}
              </SurfaceCard>
              <SurfaceCard>
                <Text style={styles.sectionTitle}>Assessment History</Text>
                {selectedCourse?.history.length ? (
                  selectedCourse.history.map((item) => (
                    <View key={item.assessmentId} style={styles.historyCard}>
                      <View style={styles.historyTop}>
                        <View style={styles.historyText}>
                          <Text style={styles.historyTitle}>{item.title}</Text>
                          <Text style={styles.muted}>{formatDate(item.date)}</Text>
                        </View>
                        <Text style={styles.historyScore}>{item.score.toFixed(1)}</Text>
                      </View>
                    </View>
                  ))
                ) : (
                  <Text style={styles.muted}>No published assessment history available yet.</Text>
                )}
              </SurfaceCard>
            </>
          )}
        </View>
      </ScrollView>
    </Screen>
  );
}

function Stat({ value, label }: { value: number; label: string }) {
  return (
    <View style={styles.stat}>
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.muted}>{label}</Text>
    </View>
  );
}

function RadarChart({
  scores,
}: {
  scores: { label: string; score: number }[];
}) {
  const size = 280;
  const center = size / 2;
  const radius = 86;
  const count = Math.max(scores.length, 3);
  const pointFor = (index: number, score: number) => {
    const angle = (-90 + (360 / count) * index) * (Math.PI / 180);
    const scaledRadius = radius * (score / 5);
    return {
      x: center + scaledRadius * Math.cos(angle),
      y: center + scaledRadius * Math.sin(angle),
    };
  };
  const outer = scores.map((_, index) => pointFor(index, 5));
  const scorePoints = scores.map((score, index) => pointFor(index, score.score));
  const points = scorePoints.map((point) => `${point.x},${point.y}`).join(' ');

  return (
    <Svg width="100%" height={size} viewBox={`0 0 ${size} ${size}`}>
      {[2, 3, 4, 5].map((mark) => (
        <Circle
          key={mark}
          cx={center}
          cy={center}
          r={radius * (mark / 5)}
          stroke="#B7C3B5"
          strokeWidth="1"
          fill="none"
        />
      ))}
      {outer.map((point, index) => (
        <Line
          key={`line-${index}`}
          x1={center}
          y1={center}
          x2={point.x}
          y2={point.y}
          stroke="#6F796D"
          strokeWidth="1"
        />
      ))}
      <Polygon points={points} fill="rgba(23,107,34,0.28)" stroke={colors.primary} strokeWidth="2" />
      {scores.map((score, index) => {
        const point = pointFor(index, 5.7);
        return (
          <SvgText
            key={score.label}
            x={point.x}
            y={point.y}
            fontSize="11"
            fill={colors.slate}
            textAnchor="middle"
          >
            {score.label.slice(0, 12)}
          </SvgText>
        );
      })}
    </Svg>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingBottom: 110 },
  body: { padding: 22, gap: 16 },
  title: { color: '#FFFFFF', fontSize: 22, fontWeight: '900' },
  subtitle: { color: '#DDE9DE', marginTop: 6 },
  sectionTitle: { color: '#111827', fontSize: 17, fontWeight: '900' },
  muted: { color: colors.muted, marginTop: 6 },
  centerMuted: { color: colors.muted, textAlign: 'center' },
  coursePills: { gap: 10, marginTop: 14 },
  coursePill: { borderWidth: 1, borderColor: colors.border, borderRadius: 16, padding: 12 },
  coursePillActive: { backgroundColor: colors.primarySoft, borderColor: colors.primary },
  coursePillText: { color: colors.slate, fontWeight: '800' },
  coursePillTextActive: { color: colors.primary },
  score: { color: colors.primary, fontSize: 48, fontWeight: '900', textAlign: 'center', marginTop: 24 },
  statsRow: { flexDirection: 'row', justifyContent: 'center', gap: 42, marginTop: 24 },
  stat: { alignItems: 'center' },
  statValue: { color: '#111827', fontSize: 24, fontWeight: '900' },
  barRow: { marginTop: 16 },
  barLabel: { color: '#111827', fontWeight: '900', marginBottom: 8 },
  barTrack: { height: 8, borderRadius: 8, backgroundColor: '#D9D9D9', overflow: 'hidden' },
  barFill: { height: 8, borderRadius: 8, backgroundColor: colors.primary },
  barValue: { color: colors.primary, fontWeight: '900', marginTop: 6, textAlign: 'right' },
  historyCard: { backgroundColor: colors.primarySoft, borderRadius: 16, padding: 14, marginTop: 12 },
  historyTop: { flexDirection: 'row', alignItems: 'center' },
  historyText: { flex: 1 },
  historyTitle: { color: '#111827', fontWeight: '900' },
  historyScore: { color: colors.primary, fontSize: 18, fontWeight: '900' },
});
