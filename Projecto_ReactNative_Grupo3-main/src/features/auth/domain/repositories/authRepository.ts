import { AuthSession, AuthUser } from '../entities/authUser';

export type AuthRepository = {
  signIn: (email: string) => Promise<AuthSession>;
  logout: () => Promise<void>;
  verifyToken: () => Promise<boolean>;
  refreshToken: () => Promise<boolean>;
  getStoredUser: () => Promise<AuthUser | null>;
  clearLocalSession: () => Promise<void>;
};
