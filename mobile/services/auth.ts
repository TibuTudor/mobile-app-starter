import api, { setAuthToken, removeAuthToken } from './api';
import {
  AuthResponse,
  LoginCredentials,
  RegisterCredentials,
  SocialLoginCredentials,
  User,
} from '../types/auth';

class AuthService {
  /**
   * Login with email and password
   */
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/login', credentials);
    await setAuthToken(response.data.token);
    return response.data;
  }

  /**
   * Register a new user
   */
  async register(credentials: RegisterCredentials): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/register', credentials);
    await setAuthToken(response.data.token);
    return response.data;
  }

  /**
   * Login with social provider (Google/Apple)
   */
  async socialLogin(credentials: SocialLoginCredentials): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/social', credentials);
    await setAuthToken(response.data.token);
    return response.data;
  }

  /**
   * Logout current user
   */
  async logout(): Promise<void> {
    try {
      await api.post('/auth/logout');
    } catch (error) {
      // Even if API call fails, clear local token
      console.error('Logout API error:', error);
    } finally {
      await removeAuthToken();
    }
  }

  /**
   * Get current authenticated user
   */
  async getCurrentUser(): Promise<User> {
    const response = await api.get<{ user: User }>('/user');
    return response.data.user;
  }

  /**
   * Check if user is authenticated (has valid token)
   */
  async checkAuth(): Promise<User | null> {
    try {
      return await this.getCurrentUser();
    } catch (error) {
      return null;
    }
  }
}

export const authService = new AuthService();
export default authService;
