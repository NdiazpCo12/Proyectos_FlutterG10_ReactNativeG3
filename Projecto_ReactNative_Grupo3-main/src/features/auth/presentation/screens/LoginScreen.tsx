import { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { HeaderBand, Screen } from '../../../../components/Screen';
import { PrimaryButton, SurfaceCard } from '../../../../components/ui';
import { useAuth } from '../context/AuthContext';
import { colors } from '../../../../theme/theme';
import { userMessage } from '../../../../utils/format';

export function LoginScreen() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const { signIn, isSubmitting } = useAuth();

  const submit = async () => {
    const normalized = email.trim().toLowerCase();
    if (!normalized) {
      setError('Ingresa el correo institucional para continuar.');
      return;
    }
    try {
      setError('');
      await signIn(normalized);
    } catch (err) {
      setError(userMessage(err, 'No fue posible iniciar sesión.'));
    }
  };

  return (
    <Screen>
      <KeyboardAvoidingView
        behavior={Platform.select({ ios: 'padding', android: undefined })}
        style={styles.flex}
      >
        <HeaderBand>
          <Text style={styles.brand}>Peer Assessment</Text>
          <Text style={styles.subtitle}>Apartado estudiante con Roble</Text>
        </HeaderBand>
        <View style={styles.content}>
          <SurfaceCard>
            <Text style={styles.title}>Iniciar sesión</Text>
            <Text style={styles.description}>
              Usa tu correo institucional. La app valida tu rol en Roble antes de entrar.
            </Text>
            <TextInput
              autoCapitalize="none"
              keyboardType="email-address"
              placeholder="correo@uninorte.edu.co"
              placeholderTextColor={colors.muted}
              value={email}
              onChangeText={setEmail}
              style={styles.input}
            />
            {error ? <Text style={styles.error}>{error}</Text> : null}
            <PrimaryButton
              label="Entrar"
              loading={isSubmitting}
              onPress={submit}
            />
          </SurfaceCard>
          <Text style={styles.footer}>Powered by Roble</Text>
        </View>
      </KeyboardAvoidingView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  brand: {
    color: '#FFFFFF',
    fontSize: 28,
    fontWeight: '900',
  },
  subtitle: {
    color: '#DDE9DE',
    fontSize: 16,
    marginTop: 6,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    padding: 22,
    gap: 18,
  },
  title: {
    color: '#111827',
    fontSize: 22,
    fontWeight: '900',
  },
  description: {
    color: colors.muted,
    lineHeight: 21,
    marginTop: 8,
    marginBottom: 18,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: '#111827',
    fontSize: 16,
    marginBottom: 14,
  },
  error: {
    color: colors.danger,
    marginBottom: 14,
    lineHeight: 20,
  },
  footer: {
    color: colors.muted,
    textAlign: 'center',
    fontWeight: '700',
  },
});
