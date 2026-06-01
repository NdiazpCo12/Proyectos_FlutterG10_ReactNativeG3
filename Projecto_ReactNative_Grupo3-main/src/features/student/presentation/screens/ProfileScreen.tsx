import { useState } from 'react';
import { Alert, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';
import {
  Bell,
  HelpCircle,
  LogOut,
  Mail,
  Shield,
  User,
} from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { colors } from '../../../../theme/theme';
import { useAuth } from '../../../auth/presentation/context/AuthContext';

export function ProfileScreen() {
  const { user, signOut } = useAuth();
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [assessmentReminders, setAssessmentReminders] = useState(true);
  const [newResults, setNewResults] = useState(true);

  const logout = () => {
    Alert.alert('Cerrar sesión', '¿Quieres salir de la app?', [
      { text: 'Cancelar', style: 'cancel' },
      { text: 'Salir', style: 'destructive', onPress: signOut },
    ]);
  };

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.title}>Profile</Text>
          <Text style={styles.subtitle}>Manage your account settings</Text>
        </HeaderBand>
        <View style={styles.body}>
          <SurfaceCard>
            <View style={styles.profileRow}>
              <View style={styles.avatar}>
                <User color={colors.primary} size={34} />
              </View>
              <View style={styles.flex}>
                <Text style={styles.name}>{user?.name || 'Student'}</Text>
                <Text style={styles.muted}>Student</Text>
              </View>
            </View>
            <InfoRow
              icon={<Mail color={colors.slate} size={18} />}
              text={user?.email || 'No email available'}
            />
            <InfoRow
              icon={<Shield color={colors.slate} size={18} />}
              text="Student Account"
            />
          </SurfaceCard>
          <SurfaceCard>
            <View style={styles.sectionHeader}>
              <Bell color={colors.primary} size={22} />
              <Text style={styles.sectionTitle}>Notifications</Text>
            </View>
            <Toggle
              label="Email Notifications"
              value={emailNotifications}
              onValueChange={setEmailNotifications}
            />
            <Toggle
              label="Assessment Reminders"
              value={assessmentReminders}
              onValueChange={setAssessmentReminders}
            />
            <Toggle
              label="New Results"
              value={newResults}
              onValueChange={setNewResults}
            />
          </SurfaceCard>
          <SurfaceCard>
            <View style={styles.sectionHeader}>
              <HelpCircle color={colors.primary} size={22} />
              <Text style={styles.sectionTitle}>Support</Text>
            </View>
            <Text style={styles.muted}>
              Peer Assessment Platform - Powered by Roble
            </Text>
          </SurfaceCard>
          <PrimaryButton label="Log Out" onPress={logout} />
          <View style={styles.logoutIcon}>
            <LogOut color={colors.danger} size={18} />
          </View>
        </View>
      </ScrollView>
    </Screen>
  );
}

function InfoRow({ icon, text }: { icon: React.ReactNode; text: string }) {
  return (
    <View style={styles.infoRow}>
      {icon}
      <Text style={styles.infoText}>{text}</Text>
    </View>
  );
}

function Toggle({
  label,
  value,
  onValueChange,
}: {
  label: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
}) {
  return (
    <View style={styles.toggleRow}>
      <Text style={styles.infoText}>{label}</Text>
      <Switch
        value={value}
        onValueChange={onValueChange}
        thumbColor={value ? colors.primary : undefined}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingBottom: 110 },
  body: { padding: 22, gap: 16 },
  title: { color: '#FFFFFF', fontSize: 22, fontWeight: '900' },
  subtitle: { color: '#DDE9DE', marginTop: 6 },
  profileRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    marginBottom: 14,
  },
  avatar: {
    width: 68,
    height: 68,
    borderRadius: 34,
    backgroundColor: colors.tint,
    alignItems: 'center',
    justifyContent: 'center',
  },
  flex: { flex: 1 },
  name: { color: '#111827', fontSize: 18, fontWeight: '900' },
  muted: { color: colors.muted, marginTop: 6 },
  infoRow: {
    flexDirection: 'row',
    gap: 12,
    alignItems: 'center',
    marginTop: 14,
  },
  infoText: { color: colors.slate, fontWeight: '700' },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 10,
  },
  sectionTitle: { color: '#111827', fontSize: 18, fontWeight: '900' },
  toggleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 10,
  },
  logoutIcon: { alignItems: 'center' },
});
