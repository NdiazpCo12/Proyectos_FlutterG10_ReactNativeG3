import { AuthUser } from '../../features/auth/domain/entities/authUser';

export type LocalPreferences = {
  saveTokens: (accessToken: string, refreshToken: string) => Promise<void>;
  getAccessToken: () => Promise<string | null>;
  getRefreshToken: () => Promise<string | null>;
  saveUser: (user: AuthUser) => Promise<void>;
  getUser: () => Promise<AuthUser | null>;
  clearSession: () => Promise<void>;
};
