import { PropsWithChildren } from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { colors, radii } from '../theme/theme';

export function SurfaceCard({ children }: PropsWithChildren) {
  return <View style={styles.card}>{children}</View>;
}

export function PrimaryButton({
  label,
  onPress,
  disabled,
  loading,
}: {
  label: string;
  onPress?: () => void;
  disabled?: boolean;
  loading?: boolean;
}) {
  return (
    <TouchableOpacity
      activeOpacity={0.85}
      disabled={disabled || loading}
      onPress={onPress}
      style={[styles.primaryButton, (disabled || loading) && styles.disabled]}
    >
      {loading ? (
        <ActivityIndicator color="#FFFFFF" />
      ) : (
        <Text style={styles.primaryButtonText}>{label}</Text>
      )}
    </TouchableOpacity>
  );
}

export function StatusChip({ label }: { label: string }) {
  const active = label === 'Active';
  const completed = label === 'Completed';
  return (
    <View
      style={[
        styles.chip,
        active && styles.chipActive,
        completed && styles.chipCompleted,
      ]}
    >
      <Text style={[styles.chipText, active && styles.chipTextActive]}>
        {label}
      </Text>
    </View>
  );
}

export function EmptyState({ title }: { title: string }) {
  return (
    <View style={styles.empty}>
      <Text style={styles.emptyText}>{title}</Text>
    </View>
  );
}

export function LoadingState() {
  return (
    <View style={styles.empty}>
      <ActivityIndicator color={colors.primary} />
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.surface,
    borderRadius: radii.lg,
    padding: 18,
    shadowColor: '#000000',
    shadowOpacity: 0.08,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 7 },
    elevation: 3,
  },
  primaryButton: {
    minHeight: 48,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radii.pill,
    backgroundColor: colors.primary,
    paddingHorizontal: 18,
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontWeight: '800',
    fontSize: 15,
  },
  disabled: {
    opacity: 0.55,
  },
  chip: {
    alignSelf: 'flex-start',
    borderRadius: radii.pill,
    backgroundColor: '#ECEFF3',
    paddingHorizontal: 12,
    paddingVertical: 6,
  },
  chipActive: {
    backgroundColor: colors.primary,
  },
  chipCompleted: {
    backgroundColor: colors.primarySoft,
  },
  chipText: {
    color: colors.slate,
    fontSize: 12,
    fontWeight: '800',
  },
  chipTextActive: {
    color: '#FFFFFF',
  },
  empty: {
    padding: 36,
    alignItems: 'center',
  },
  emptyText: {
    color: colors.muted,
    textAlign: 'center',
  },
});
