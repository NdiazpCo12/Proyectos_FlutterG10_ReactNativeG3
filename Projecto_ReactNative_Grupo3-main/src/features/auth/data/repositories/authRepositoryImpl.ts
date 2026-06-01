import { AuthRepository } from '../../domain/repositories/authRepository';
import { authService } from '../datasources/authDatasource';

export const authRepository: AuthRepository = {
  signIn: authService.signIn,
  logout: authService.logout,
  verifyToken: authService.verifyToken,
  refreshToken: authService.refreshToken,
  getStoredUser: authService.getStoredUser,
  clearLocalSession: authService.clearLocalSession,
};
