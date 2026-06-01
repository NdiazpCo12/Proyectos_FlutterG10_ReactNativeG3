import axios from 'axios';

import { robleConfig } from '../../../../config/robleConfig';
import { AuthSession, AuthUser } from '../../domain/entities/authUser';
import { sessionStorage } from '../../../../core/local/LocalPreferencesAsyncStorage';
import { normalizeDisplayText } from '../../../../utils/text';

type LoginBody = {
  accessToken?: string;
  refreshToken?: string;
  user?: Partial<AuthUser>;
  message?: string | string[];
};

const jsonHeaders = { 'Content-Type': 'application/json; charset=UTF-8' };

const messageFrom = (body: unknown, fallback: string) => {
  const value = body as { message?: unknown };
  if (typeof value?.message === 'string' && value.message.trim()) {
    return normalizeDisplayText(value.message);
  }
  if (Array.isArray(value?.message)) {
    return normalizeDisplayText(value.message.join(', '));
  }
  return normalizeDisplayText(fallback);
};

export const defaultUserPassword = 'ThePassword!1';

export { resolveAppRole } from '../../domain/entities/appRole';

export const isStudentRole = (role: string) => {
  const normalized = role.trim().toLowerCase();
  return (
    normalized === 'estudiante' ||
    normalized === 'student' ||
    normalized === 'alumno'
  );
};

export const isTeacherRole = (role: string) => {
  const normalized = role.trim().toLowerCase();
  return (
    normalized === 'teacher' ||
    normalized === 'docente' ||
    normalized === 'profesor' ||
    normalized === 'admin'
  );
};

export const authService = {
  async signIn(email: string, password = defaultUserPassword) {
    try {
      const response = await axios.post<LoginBody>(
        `${robleConfig.authBaseUrl}/login`,
        { email, password },
        { headers: jsonHeaders },
      );
      const user = response.data.user ?? {};
      const session: AuthSession = {
        accessToken: response.data.accessToken ?? '',
        refreshToken: response.data.refreshToken ?? '',
        user: {
          id: normalizeDisplayText(user.id ?? ''),
          email: normalizeDisplayText(user.email ?? ''),
          name: normalizeDisplayText(user.name ?? ''),
          role: normalizeDisplayText(user.role ?? ''),
        },
      };

      if (!session.accessToken || !session.refreshToken) {
        throw new Error('No fue posible iniciar sesión en este momento.');
      }

      await sessionStorage.saveTokens(
        session.accessToken,
        session.refreshToken,
      );
      await sessionStorage.saveUser(session.user);
      return session;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new Error(
          messageFrom(error.response?.data, 'No se pudo iniciar sesión.'),
        );
      }
      throw error;
    }
  },

  async logout() {
    const token = await sessionStorage.getAccessToken();
    if (!token) {
      await sessionStorage.clearSession();
      return;
    }

    try {
      await axios.post(`${robleConfig.authBaseUrl}/logout`, undefined, {
        headers: { Authorization: `Bearer ${token}` },
      });
    } finally {
      await sessionStorage.clearSession();
    }
  },

  async verifyToken() {
    const token = await sessionStorage.getAccessToken();
    if (!token) return false;
    try {
      const response = await axios.get(`${robleConfig.authBaseUrl}/verify-token`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      return response.status === 200;
    } catch {
      return false;
    }
  },

  async refreshToken() {
    const refreshToken = await sessionStorage.getRefreshToken();
    if (!refreshToken) return false;
    try {
      const response = await axios.post<LoginBody>(
        `${robleConfig.authBaseUrl}/refresh-token`,
        { refreshToken },
        { headers: jsonHeaders },
      );
      const accessToken = response.data.accessToken ?? '';
      const newRefreshToken = response.data.refreshToken ?? refreshToken;
      if (!accessToken) return false;
      await sessionStorage.saveTokens(accessToken, newRefreshToken);
      return true;
    } catch {
      return false;
    }
  },

  getStoredUser: sessionStorage.getUser,
  clearLocalSession: sessionStorage.clearSession,
};
