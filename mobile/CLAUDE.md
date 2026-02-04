# Mobile App Setup Instructions for Claude Code

## Overview

This document provides instructions for Claude Code to set up the React Native (Expo) mobile app with authentication.

## Setup Steps

### 1. Create Expo Project

```bash
npx create-expo-app@latest . --template tabs
```

### 2. Install Dependencies

```bash
npx expo install expo-auth-session expo-web-browser expo-crypto expo-secure-store
npm install axios zustand
```

### 3. Copy Starter Files

Copy all files from `starter-files/` to their respective locations:

- `starter-files/app/(auth)/login.tsx` → `app/(auth)/login.tsx`
- `starter-files/app/(auth)/register.tsx` → `app/(auth)/register.tsx`
- `starter-files/app/(auth)/_layout.tsx` → `app/(auth)/_layout.tsx`
- `starter-files/app/(tabs)/profile.tsx` → `app/(tabs)/profile.tsx`
- `starter-files/app/_layout.tsx` → `app/_layout.tsx`
- `starter-files/services/api.ts` → `services/api.ts`
- `starter-files/services/auth.ts` → `services/auth.ts`
- `starter-files/store/authStore.ts` → `store/authStore.ts`
- `starter-files/types/auth.ts` → `types/auth.ts`

### 4. Create Environment File

Create `.env` in the project root:

```env
EXPO_PUBLIC_API_URL=http://localhost:8000/api
EXPO_PUBLIC_GOOGLE_CLIENT_ID=your_google_web_client_id
EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id
EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID=your_google_android_client_id
```

### 5. Update app.json

Add to `app.json`:

```json
{
  "expo": {
    "scheme": "myapp",
    "ios": {
      "bundleIdentifier": "com.yourcompany.myapp",
      "usesAppleSignIn": true
    },
    "android": {
      "package": "com.yourcompany.myapp"
    }
  }
}
```

### 6. Start Development

```bash
npx expo start
```

### Alternative: Docker Setup

Instead of steps 1-6, you can run the entire stack from the project root:

```bash
cd ..
cp .env.example .env   # Set HOST_IP to your LAN IP
docker compose up --build
```

This starts the Expo Metro bundler (port 8082), the Laravel API (port 8000), MySQL, and phpMyAdmin. The mobile entrypoint handles `npm ci` and starting Metro automatically.

Docker files:
- `Dockerfile` — Node 20-slim with git
- `docker-entrypoint.sh` — runs `npm ci`, starts Metro with `EXPO_NO_INTERACTIVE=1`
- `.dockerignore` — excludes node_modules/, .expo/, dist/, ios/, android/

The Metro bundler runs inside Docker but the app itself runs on your physical device or emulator. `REACT_NATIVE_PACKAGER_HOSTNAME` is set to your LAN IP so the QR code points to the correct address.

## File Descriptions

### services/api.ts
Axios instance configured with:
- Base URL from environment
- Auth token injection via interceptors
- Response error handling
- Web-compatible token storage (SecureStore on native, localStorage on web)

### services/auth.ts
Authentication service with:
- `login()` - Email/password login
- `register()` - Email/password registration
- `socialLogin()` - Google/Apple OAuth
- `logout()` - Token revocation
- Token storage using expo-secure-store (with localStorage fallback on web)

### store/authStore.ts
Zustand store managing:
- User state
- Authentication status
- Loading states
- Auth actions

### app/(auth)/*
Authentication screens:
- Login screen with email and social options
- Register screen
- Auth layout

### types/auth.ts
TypeScript interfaces for:
- User
- AuthResponse
- LoginCredentials
- RegisterCredentials

## OAuth Setup

### Google Sign-In

1. Configure in Google Cloud Console
2. Create OAuth 2.0 credentials for:
   - Web (for Expo Go development)
   - iOS
   - Android
3. Add client IDs to `.env`

### Apple Sign-In

1. Enable Sign In with Apple in Apple Developer Portal
2. Add capability to your App ID
3. Configure in Expo (usesAppleSignIn: true)

## Testing

### With Expo Go

```bash
npx expo start
```

Scan QR code with Expo Go app.

### With Development Build

```bash
npx expo prebuild
npx expo run:ios
# or
npx expo run:android
```

## Notes

- For local development, use your computer's IP instead of localhost
- iOS Simulator and Android Emulator need different API URLs
- Social login requires development builds for full functionality
- Web platform is supported: `expo-secure-store` falls back to `localStorage`, `Alert.alert` falls back to `window.alert`
- When using Docker, the Metro bundler is exposed on host port 8082 (container port 8081)
