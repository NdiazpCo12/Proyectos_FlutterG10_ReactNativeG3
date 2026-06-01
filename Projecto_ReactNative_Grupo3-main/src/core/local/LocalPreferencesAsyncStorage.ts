import AsyncStorage from '@react-native-async-storage/async-storage';

import { AuthUser } from '../../features/auth/domain/entities/authUser';
import { normalizeDisplayText } from '../../utils/text';
import { LocalPreferences } from './LocalPreferences';

const keys = {
  accessToken: 'accessToken',
  refreshToken: 'refreshToken',
  user: 'user',
};

const normalizeUser = (user: AuthUser): AuthUser => ({
  id: normalizeDisplayText(user.id),
  email: normalizeDisplayText(user.email),
  name: normalizeDisplayText(user.name),
  role: normalizeDisplayText(user.role),
});

export const sessionStorage: LocalPreferences = {
  async saveTokens(accessToken: string, refreshToken: string) {
    await Promise.all([
      AsyncStorage.setItem(keys.accessToken, accessToken),
      AsyncStorage.setItem(keys.refreshToken, refreshToken),
    ]);
  },

  async getAccessToken() {
    return AsyncStorage.getItem(keys.accessToken);
  },

  async getRefreshToken() {
    return AsyncStorage.getItem(keys.refreshToken);
  },

  async saveUser(user: AuthUser) {
    await AsyncStorage.setItem(keys.user, JSON.stringify(normalizeUser(user)));
  },

  async getUser(): Promise<AuthUser | null> {
    const rawUser = await AsyncStorage.getItem(keys.user);
    if (!rawUser) return null;
    try {
      return normalizeUser(JSON.parse(rawUser) as AuthUser);
    } catch {
      return null;
    }
  },

  async clearSession() {
    await Promise.all([
      AsyncStorage.removeItem(keys.accessToken),
      AsyncStorage.removeItem(keys.refreshToken),
      AsyncStorage.removeItem(keys.user),
    ]);
  },
};
