# Backend Setup Instructions for Claude Code

## Overview

This document provides instructions for Claude Code to set up the Laravel backend with authentication.

## Setup Steps

### 1. Create Laravel Project

```bash
composer create-project laravel/laravel . --prefer-dist
```

### 2. Install Dependencies

```bash
composer require laravel/sanctum laravel/socialite
```

### 3. Publish Sanctum Configuration

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 4. Copy Starter Files

Copy all files from `starter-files/` to their respective locations:

- `starter-files/app/Http/Controllers/AuthController.php` → `app/Http/Controllers/AuthController.php`
- `starter-files/app/Models/User.php` → `app/Models/User.php`
- `starter-files/routes/api.php` → `routes/api.php`
- `starter-files/config/services.php` → `config/services.php`
- `starter-files/config/cors.php` → `config/cors.php`
- `starter-files/database/migrations/add_social_fields_to_users.php` → `database/migrations/[timestamp]_add_social_fields_to_users.php`

### 5. Configure Environment

Update `.env` with:

```env
SANCTUM_STATEFUL_DOMAINS=localhost,localhost:8000,127.0.0.1,127.0.0.1:8000

GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/auth/google/callback

APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
APPLE_REDIRECT_URI=http://localhost:8000/api/auth/apple/callback
```

### 6. Run Migrations

```bash
php artisan migrate
```

### 7. Start Development Server

```bash
php artisan serve
```

### Alternative: Docker Setup

Instead of steps 1-7, you can run the entire stack from the project root:

```bash
cd ..
cp .env.example .env   # Set HOST_IP to your LAN IP
docker compose up --build
```

This starts MySQL, the Laravel API (port 8000), phpMyAdmin (port 8090), and the Expo Metro bundler (port 8082). The backend entrypoint handles `composer install`, `.env` configuration, migrations, and starting the server automatically.

Docker files:
- `Dockerfile` — PHP 8.2-cli with pdo_mysql, zip, bcmath, gd, mbstring, xml + Composer 2
- `docker-entrypoint.sh` — installs deps, patches `.env` for MySQL, waits for DB, migrates, serves
- `.dockerignore` — excludes vendor/, .env, storage/logs, database.sqlite

Running artisan commands in Docker:
```bash
docker compose exec backend php artisan tinker
docker compose exec backend php artisan migrate:status
```

## File Descriptions

### AuthController.php
Handles all authentication:
- `register()` - Email/password registration
- `login()` - Email/password login
- `socialLogin()` - Google/Apple OAuth token exchange
- `logout()` - Token revocation
- `user()` - Get authenticated user

### User.php
Extended User model with:
- Social provider fields (provider, provider_id, avatar)
- Sanctum HasApiTokens trait

### api.php
API routes:
- Public: register, login, social login
- Protected: user, logout

### services.php
OAuth provider configuration for Google and Apple.

### cors.php
CORS configuration allowing mobile app requests.

## Testing the API

### Register
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","password_confirmation":"password123"}'
```

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Get User (with token)
```bash
curl http://localhost:8000/api/user \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
