# Mobile App Starter - Laravel + React Native

A cross-platform mobile app skeleton with authentication (Email, Google, Apple) using Laravel backend and React Native (Expo) frontend.

## Project Structure

```
mobile-app-starter/
├── backend/                 # Laravel API
│   ├── CLAUDE.md           # Instructions for Claude Code
│   ├── setup.sh            # Automated setup script
│   └── starter-files/      # Pre-configured files to copy
└── mobile/                  # React Native (Expo) app
    ├── CLAUDE.md           # Instructions for Claude Code
    ├── setup.sh            # Automated setup script
    └── starter-files/      # Pre-configured files to copy
```

## Quick Start with Claude Code

### Option 1: Let Claude Code Set It Up

Open Claude Code in this directory and say:

```
Set up the Laravel backend following backend/CLAUDE.md
```

Then:

```
Set up the React Native mobile app following mobile/CLAUDE.md
```

### Option 2: Manual Setup

#### Backend (Laravel)

```bash
cd backend
chmod +x setup.sh
./setup.sh
```

#### Mobile (React Native)

```bash
cd mobile
chmod +x setup.sh
./setup.sh
```

## Features

### Authentication
- ✅ Email/Password registration and login
- ✅ Google OAuth sign-in
- ✅ Apple Sign-In
- ✅ Token-based API authentication (Sanctum)
- ✅ Secure token storage on mobile

### Backend (Laravel)
- Laravel 11 with Sanctum for API tokens
- Socialite for OAuth providers
- RESTful API structure
- User model with social provider tracking
- CORS configured for mobile

### Mobile (React Native)
- Expo SDK 52+
- TypeScript
- Expo Router for navigation
- expo-auth-session for OAuth
- expo-secure-store for token persistence
- Pre-built auth screens

## Environment Variables

### Backend (.env)

```env
APP_URL=http://localhost:8000
DB_CONNECTION=mysql
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password

GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
```

### Mobile (.env)

```env
EXPO_PUBLIC_API_URL=http://localhost:8000/api
EXPO_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id
EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID=your_google_android_client_id
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register with email/password |
| POST | `/api/auth/login` | Login with email/password |
| POST | `/api/auth/social` | Login with social provider token |
| POST | `/api/auth/logout` | Logout (revoke token) |
| GET | `/api/user` | Get authenticated user |

## Setting Up OAuth

### Google

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs for your app

### Apple

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Register an App ID with Sign In with Apple capability
3. Create a Services ID for web authentication
4. Generate a private key for Sign In with Apple

## Development

### Running Backend

```bash
cd backend
php artisan serve
```

### Running Mobile

```bash
cd mobile
npx expo start
```

## Extending This Skeleton

This POC is designed to be extended. Common next steps:

1. Add more API routes in `routes/api.php`
2. Create new screens in `mobile/app/`
3. Add database migrations for your models
4. Implement push notifications
5. Add file upload handling

## License

MIT
