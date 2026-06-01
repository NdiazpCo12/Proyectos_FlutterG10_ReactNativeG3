import { useState } from 'react';
import {
  Alert,
  Linking,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
} from 'react-native';
import { Bell, HelpCircle, LogOut, Mail, Shield, User } from 'lucide-react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { colors, spacing } from '../../../../theme/theme';
import { useAuth } from '../../../auth/presentation/context/AuthContext';

export function TeacherProfileScreen() {
  const { user, signOut } = useAuth();
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [assessmentReminders, setAssessmentReminders] = useState(true);
  const [newResults, setNewResults] = useState(true);

  const openSupportEmail = async () => {
    const url = 'mailto:support@roble.com';
    const supported = await Linking.canOpenURL(url);
    if (!supported) {
      Alert.alert('Soporte', 'No pudimos abrir tu app de correo.');
      return;
    }
    await Linking.openURL(url);
  };

  const openHelpCenter = async () => {
    const url = 'https://roble.edu.ec';
    const supported = await Linking.canOpenURL(url);
    if (!supported) {
      Alert.alert('Centro de ayuda', 'No pudimos abrir el enlace de ayuda.');
      return;
    }
    await Linking.openURL(url);
  };

  const logout = () => {
    Alert.alert('Cerrar sesión', '¿Querés salir de tu cuenta docente?', [
      { text: 'Cancelar', style: 'cancel' },
      { text: 'Salir', style: 'destructive', onPress: () => signOut() },
    ]);
  };

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.scroll}>
        <HeaderBand>
          <Text style={styles.headerTitle}>Perfil</Text>
          <Text style={styles.headerSubtitle}>Configuración y soporte docente</Text>
        </HeaderBand>
        <View style={styles.content}>
          <SurfaceCard>
            <View style={styles.profileRow}>
              <View style={styles.avatar}>
                <User color={colors.primary} size={32} />
              </View>
              <View style={styles.profileInfo}>
                <Text style={styles.name}>{user?.name ?? 'Docente'}</Text>
                <View style={styles.roleBadge}>
                  <Text style={styles.roleText}>Docente</Text>
                </View>
              </View>
            </View>

            <InfoRow
              icon={<Mail color={colors.slate} size={18} />}
              label="Correo"
              value={user?.email ?? 'Sin correo'}
            />
            <InfoRow
              icon={<Bell color={colors.slate} size={18} />}
              label="Departamento"
              value="Computer Science Department"
            />
            <InfoRow
              icon={<Shield color={colors.slate} size={18} />}
              label="Tipo de cuenta"
              value="Teacher Account"
            />
          </SurfaceCard>

          <SurfaceCard>
            <View style={styles.sectionHeader}>
              <Bell color={colors.primary} size={22} />
              <Text style={styles.sectionTitle}>Notificaciones</Text>
            </View>
            <Toggle
              label="Email notifications"
              value={emailNotifications}
              onValueChange={setEmailNotifications}
            />
            <Toggle
              label="Assessment reminders"
              value={assessmentReminders}
              onValueChange={setAssessmentReminders}
            />
            <Toggle
              label="New results"
              value={newResults}
              onValueChange={setNewResults}
            />
            <Text style={styles.helperText}>
              Estos cambios son solo visuales y no se guardan entre sesiones.
            </Text>
          </SurfaceCard>

          <SurfaceCard>
            <View style={styles.sectionHeader}>
              <HelpCircle color={colors.primary} size={22} />
              <Text style={styles.sectionTitle}>Soporte</Text>
            </View>
            <Text style={styles.supportLink} onPress={openHelpCenter}>
              Help Center
            </Text>
            <Text style={styles.supportLink} onPress={openSupportEmail}>
              Contact Support
            </Text>
          </SurfaceCard>

          <PrimaryButton label="Cerrar sesión" onPress={logout} />
          <View style={styles.logoutIconRow}>
            <LogOut color={colors.danger} size={18} />
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerTitle}>Peer Assessment Platform</Text>
            <Text style={styles.footerCopy}>Powered by Roble • Version 1.0.0</Text>
          </View>
        </View>
      </ScrollView>
    </Screen>
  );
}

function InfoRow({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
}) {
  return (
    <View style={styles.infoRow}>
      {icon}
      <View style={styles.infoContent}>
        <Text style={styles.infoLabel}>{label}</Text>
        <Text style={styles.infoValue}>{value}</Text>
      </View>
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
      <Text style={styles.toggleLabel}>{label}</Text>
      <Switch
        value={value}
        onValueChange={onValueChange}
        thumbColor={value ? colors.primary : undefined}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  scroll: {
    paddingBottom: spacing.xl,
  },
  headerTitle: {
    color: '#FFFFFF',
    fontSize: 24,
    fontWeight: '900',
  },
  headerSubtitle: {
    color: '#DDE9DE',
    marginTop: spacing.sm,
  },
  content: {
    padding: spacing.lg,
    gap: spacing.md,
  },
  profileRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: spacing.md,
    marginBottom: spacing.sm,
  },
  avatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.primarySoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  profileInfo: {
    flex: 1,
  },
  name: {
    fontSize: 18,
    fontWeight: '800',
    color: '#111827',
  },
  roleBadge: {
    backgroundColor: colors.primarySoft,
    borderRadius: 8,
    paddingHorizontal: 8,
    paddingVertical: 2,
    marginTop: 6,
    alignSelf: 'flex-start',
  },
  roleText: {
    fontSize: 12,
    fontWeight: '700',
    color: colors.primary,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    marginTop: spacing.md,
  },
  infoContent: {
    flex: 1,
  },
  infoLabel: {
    color: colors.muted,
    fontSize: 12,
    fontWeight: '700',
  },
  infoValue: {
    color: colors.slate,
    fontWeight: '700',
    marginTop: 2,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    marginBottom: spacing.sm,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: '#111827',
  },
  toggleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.md,
    paddingVertical: spacing.sm,
  },
  toggleLabel: {
    color: colors.slate,
    fontWeight: '700',
    flex: 1,
  },
  helperText: {
    color: colors.muted,
    marginTop: spacing.sm,
    lineHeight: 20,
  },
  supportLink: {
    color: colors.primary,
    fontWeight: '800',
    marginTop: spacing.sm,
  },
  logoutIconRow: {
    alignItems: 'center',
  },
  footer: {
    alignItems: 'center',
    paddingBottom: spacing.md,
  },
  footerTitle: {
    color: '#111827',
    fontWeight: '800',
  },
  footerCopy: {
    color: colors.muted,
    marginTop: spacing.xs,
  },
});
