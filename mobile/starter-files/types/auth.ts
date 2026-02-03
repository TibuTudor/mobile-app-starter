export interface User {
  id: number;
  name: string;
  email: string;
  avatar?: string | null;
  provider?: string | null;
  email_verified_at?: string | null;
  created_at: string;
  updated_at: string;
}

export interface AuthResponse {
  message: string;
  user: User;
  token: string;
  token_type: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials {
  name: string;
  email: string;
  password: string;
  password_confirmation: string;
}

export interface SocialLoginCredentials {
  provider: 'google' | 'apple';
  access_token: string;
  identity_token?: string;
  name?: string;
  email?: string;
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
}
