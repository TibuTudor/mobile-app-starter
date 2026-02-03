# Setup Guide

Step-by-step instructions for getting the backend and mobile app running from scratch.

## Prerequisites

| Tool | Version | Check |
|------|---------|-------|
| PHP | 8.2+ | `php -v` |
| Composer | 2.x | `composer -V` |
| Node.js | 20+ | `node -v` |
| nvm | (recommended) | `nvm --version` |
| Expo CLI | (installed via npx) | `npx expo --version` |

## Backend Setup (Laravel)

```bash
cd backend
```

### 1. Create the Laravel project

```bash
composer create-project laravel/laravel . --prefer-dist
```

### 2. Install dependencies

```bash
composer require laravel/sanctum laravel/socialite
```

### 3. Publish Sanctum config

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 4. Copy starter files

Copy everything from `starter-files/` into the project:

```bash
cp starter-files/app/Http/Controllers/AuthController.php app/Http/Controllers/AuthController.php
cp starter-files/app/Models/User.php app/Models/User.php
cp starter-files/routes/api.php routes/api.php
cp starter-files/config/services.php config/services.php
cp starter-files/config/cors.php config/cors.php

# Timestamp the migration
cp starter-files/database/migrations/add_social_fields_to_users.php \
   database/migrations/$(date +%Y_%m_%d_%H%M%S)_add_social_fields_to_users.php
```

### 5. Fix `bootstrap/app.php` (Laravel 11)

Laravel 11 ships **without** the `api:` route entry in `bootstrap/app.php`. You must add it or your `routes/api.php` file will never load.

Open `bootstrap/app.php` and make sure `->withRouting(...)` includes the `api:` line:

```php
->withRouting(
    web: __DIR__.'/../routes/web.php',
    api: __DIR__.'/../routes/api.php',   // <-- add this line
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
)
```

> **Note:** The starter files in this repo already have this fix applied, but if you ever regenerate the Laravel skeleton you will need to add it again.

### 6. Configure `.env`

```bash
cp .env.example .env
php artisan key:generate
```

Then edit `.env` and set your database credentials and OAuth keys:

```
DB_CONNECTION=mysql
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password

SANCTUM_STATEFUL_DOMAINS=localhost,localhost:8000,127.0.0.1,127.0.0.1:8000

GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/auth/google/callback

APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
APPLE_REDIRECT_URI=http://localhost:8000/api/auth/apple/callback
```

### 7. Run migrations

```bash
php artisan migrate
```

### 8. Start the dev server

Use `--host=0.0.0.0` so the mobile app can reach it over your local network:

```bash
php artisan serve --host=0.0.0.0
```

The API will be available at `http://<YOUR_MACHINE_IP>:8000/api`.

---

## Mobile Setup (React Native / Expo)

```bash
cd mobile
```

### 1. Create the Expo project

```bash
npx create-expo-app@latest . --template tabs
```

### 2. Install dependencies

```bash
npx expo install expo-auth-session expo-web-browser expo-crypto expo-secure-store
npm install axios zustand
```

### 3. Copy starter files

```bash
mkdir -p app/\(auth\) services store types

cp starter-files/app/\(auth\)/login.tsx   app/\(auth\)/login.tsx
cp starter-files/app/\(auth\)/register.tsx app/\(auth\)/register.tsx
cp starter-files/app/\(auth\)/_layout.tsx  app/\(auth\)/_layout.tsx
cp starter-files/app/\(tabs\)/profile.tsx  app/\(tabs\)/profile.tsx
cp starter-files/app/_layout.tsx           app/_layout.tsx
cp starter-files/services/api.ts           services/api.ts
cp starter-files/services/auth.ts          services/auth.ts
cp starter-files/store/authStore.ts        store/authStore.ts
cp starter-files/types/auth.ts             types/auth.ts
```

### 4. Configure `.env`

```bash
cp .env.example .env
```

Edit `.env` and replace `YOUR_MACHINE_IP` with your computer's local IP (e.g. `192.168.1.42`). You can find it with:

```bash
# macOS
ipconfig getifaddr en0

# Linux
hostname -I | awk '{print $1}'
```

### 5. Start the dev server

```bash
npx expo start
```

Scan the QR code with Expo Go on your phone, or press `i` / `a` for a simulator.

---

## Testing the API

With the backend running (`php artisan serve --host=0.0.0.0`):

### Health check

```bash
curl http://localhost:8000/api/health
```

### Register

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Get authenticated user

```bash
curl http://localhost:8000/api/user \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Logout

```bash
curl -X POST http://localhost:8000/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Docker Setup (Alternative)

Run the entire stack (MySQL, Laravel API, Expo Metro bundler) with a single command. No need to install PHP, Composer, or Node on your host.

### Prerequisites

| Tool | Version | Check |
|------|---------|-------|
| Docker | 20+ | `docker --version` |
| Docker Compose | v2+ | `docker compose version` |

### 1. Configure environment

```bash
cp .env.example .env
```

Edit `.env` at the project root and set `HOST_IP` to your machine's LAN IP:

```bash
# macOS
ipconfig getifaddr en0

# Linux
hostname -I | awk '{print $1}'
```

Update the value in `.env`:

```
HOST_IP=192.168.1.42   # ← your actual IP
```

### 2. Start everything

```bash
docker compose up --build
```

First run will take a few minutes to download images and install dependencies. Subsequent starts are fast because dependencies are cached in named volumes.

### 3. Verify services

```bash
# API health check
curl http://localhost:8000/api/health

# Migration status
docker compose exec backend php artisan migrate:status

# Metro bundler logs (should show QR code URL)
docker compose logs mobile
```

### 4. Connect from a physical device

1. Make sure your phone is on the **same Wi-Fi** as your computer
2. Open Expo Go and scan the QR code from the Metro bundler logs
3. The app will connect to `http://HOST_IP:8000/api` for API calls

### 5. Connect from Android emulator

```bash
adb reverse tcp:8081 tcp:8081
adb reverse tcp:8000 tcp:8000
```

Then connect to `exp://localhost:8081` in the emulator.

### 6. Common Docker commands

```bash
# Stop all services
docker compose down

# Stop and remove volumes (fresh start)
docker compose down -v

# Rebuild a single service
docker compose up --build backend

# Run artisan commands
docker compose exec backend php artisan tinker
docker compose exec backend php artisan migrate:fresh --seed

# View logs
docker compose logs -f backend
docker compose logs -f mobile

# Access MySQL from host
mysql -h 127.0.0.1 -P 3307 -u laravel -p
```

### 7. Database access

**phpMyAdmin** is available at `http://localhost:8090`. Log in with your `DB_USERNAME`/`DB_PASSWORD` or `root`/`DB_ROOT_PASSWORD`.

MySQL is also exposed on `127.0.0.1:3307` for CLI or GUI clients:

| Setting | Value |
|---------|-------|
| Host | `127.0.0.1` |
| Port | `3307` |
| Database | value of `DB_DATABASE` |
| Username | value of `DB_USERNAME` |
| Password | value of `DB_PASSWORD` |

### Troubleshooting

**Metro QR code points to wrong IP:**
Make sure `HOST_IP` in `.env` matches your current LAN IP. Restart with `docker compose up`.

**`npm ci` or `composer install` fails:**
Clear named volumes and rebuild: `docker compose down -v && docker compose up --build`.

**Port conflicts:**
If 3307, 8000, 8081, or 8090 are already in use, stop the conflicting service or use `docker-compose.override.yml` to remap ports.

**MySQL connection refused in backend:**
The entrypoint waits up to 60 seconds for MySQL. Check `docker compose logs db` for errors.
