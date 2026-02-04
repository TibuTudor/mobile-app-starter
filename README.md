# Mobile App Starter - Laravel + React Native

A cross-platform mobile app skeleton with authentication (Email, Google, Apple) using Laravel backend and React Native (Expo) frontend. Includes a Docker Compose setup to run the entire stack with a single command.

## Project Structure

```
mobile-app-starter/
├── docker-compose.yml       # Orchestrates all services
├── .env.example             # Docker Compose variables (HOST_IP, DB creds)
├── SETUP.md                 # Detailed setup guide
├── backend/                 # Laravel API
│   ├── Dockerfile           # PHP 8.2-cli + extensions + Composer
│   ├── docker-entrypoint.sh # composer install, wait for DB, migrate, serve
│   ├── .dockerignore
│   ├── CLAUDE.md            # Instructions for Claude Code
│   ├── setup.sh             # Manual setup script (non-Docker)
│   └── starter-files/       # Pre-configured files to copy
└── mobile/                  # React Native (Expo) app
    ├── Dockerfile           # Node 20 + Expo CLI
    ├── docker-entrypoint.sh # npm ci, start Metro bundler
    ├── .dockerignore
    ├── CLAUDE.md            # Instructions for Claude Code
    ├── setup.sh             # Manual setup script (non-Docker)
    └── starter-files/       # Pre-configured files to copy
```

## Quick Start with Docker (Recommended)

Run the entire stack — MySQL, Laravel API, Expo Metro bundler, and phpMyAdmin — with one command. No need to install PHP, Composer, or Node on your host.

### Prerequisites

- [Docker](https://www.docker.com/) 20+ with Compose v2+

### 1. Configure environment

```bash
cp .env.example .env
```

Set `HOST_IP` to your machine's LAN IP:

```bash
# macOS
ipconfig getifaddr en0

# Linux
hostname -I | awk '{print $1}'
```

### 2. Start everything

```bash
docker compose up --build
```

### 3. Verify

| Service | URL | Notes |
|---------|-----|-------|
| Laravel API | http://localhost:8000/api/health | Returns `{"status":"ok"}` |
| Expo Metro | http://localhost:8082 | Metro bundler (scan QR with Expo Go) |
| phpMyAdmin | http://localhost:8090 | DB admin UI |
| MySQL | `127.0.0.1:3307` | Connect with any DB client |

### 4. Connect from your phone

Make sure your phone is on the same Wi-Fi as your computer, then scan the QR code from the Metro bundler logs with Expo Go.

For full Docker documentation, see [SETUP.md](SETUP.md#docker-setup-alternative).

---

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
- Email/Password registration and login
- Google OAuth sign-in
- Apple Sign-In
- Token-based API authentication (Sanctum)
- Secure token storage on mobile (SecureStore on native, localStorage on web)

### Backend (Laravel)
- Laravel 12 with Sanctum for API tokens
- Socialite for OAuth providers
- RESTful API structure
- User model with social provider tracking
- CORS configured for mobile
- Dockerized with MySQL 8.0

### Mobile (React Native)
- Expo SDK 52+
- TypeScript
- Expo Router for navigation
- expo-auth-session for OAuth
- expo-secure-store for token persistence (with web fallback)
- Web platform support
- Pre-built auth screens (login, register, profile)

## Docker Services

| Service | Image | Host Port | Description |
|---------|-------|-----------|-------------|
| **db** | mysql:8.0 | 3307 | MySQL database with persistent volume |
| **backend** | PHP 8.2-cli | 8000 | Laravel API server |
| **phpmyadmin** | phpmyadmin:5 | 8090 | Database admin UI |
| **mobile** | Node 20 | 8082 | Expo Metro bundler |

## Environment Variables

### Root `.env` (Docker Compose)

```env
HOST_IP=192.168.1.X       # Your machine's LAN IP
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
DB_ROOT_PASSWORD=rootsecret
APP_KEY=                   # Auto-generated on first run
```

### Backend `.env`

```env
APP_URL=http://localhost:8000
DB_CONNECTION=mysql
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password

SANCTUM_STATEFUL_DOMAINS=localhost,localhost:8000

GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
```

### Mobile `.env`

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

### With Docker

```bash
# Start all services
docker compose up --build

# Stop all services
docker compose down

# Rebuild a single service
docker compose up --build backend

# Run artisan commands
docker compose exec backend php artisan tinker

# View logs
docker compose logs -f backend
docker compose logs -f mobile

# Fresh database
docker compose exec backend php artisan migrate:fresh --seed
```

### Without Docker

```bash
# Backend
cd backend
php artisan serve --host=0.0.0.0

# Mobile
cd mobile
npx expo start
```

## Extending This Skeleton

This starter is designed to be extended. Common next steps:

1. Add more API routes in `routes/api.php`
2. Create new screens in `mobile/app/`
3. Add database migrations for your models
4. Implement push notifications
5. Add file upload handling

## License

MIT
