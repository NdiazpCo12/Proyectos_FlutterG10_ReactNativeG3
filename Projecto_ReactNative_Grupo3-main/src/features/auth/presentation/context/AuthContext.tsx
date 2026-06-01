import {
  createContext,
  PropsWithChildren,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';

import { AuthUser } from '../../domain/entities/authUser';
import { authRepository } from '../../data/repositories/authRepositoryImpl';
import type { AppRole } from '../../domain/entities/appRole';
import { resolveAppRole } from '../../data/datasources/authDatasource';

type AuthContextValue = {
  user: AuthUser | null;
  appRole: AppRole;
  isBootstrapping: boolean;
  isSubmitting: boolean;
  signIn: (email: string) => Promise<void>;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: PropsWithChildren) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isBootstrapping, setIsBootstrapping] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    let mounted = true;
    const restore = async () => {
      const storedUser = await authRepository.getStoredUser();
      const valid = await authRepository.verifyToken();
      if (mounted) {
        setUser(valid && storedUser ? storedUser : null);
        setIsBootstrapping(false);
      }
    };
    restore();
    return () => {
      mounted = false;
    };
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      appRole: user ? resolveAppRole(user.role) : 'unknown',
      isBootstrapping,
      isSubmitting,
      async signIn(email: string) {
        setIsSubmitting(true);
        try {
          const session = await authRepository.signIn(email);
          setUser(session.user);
        } finally {
          setIsSubmitting(false);
        }
      },
      async signOut() {
        await authRepository.logout();
        setUser(null);
      },
    }),
    [isBootstrapping, isSubmitting, user],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export const useAuth = () => {
  const value = useContext(AuthContext);
  if (!value) {
    throw new Error('useAuth must be used inside AuthProvider');
  }
  return value;
};
