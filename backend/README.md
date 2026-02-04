# Backend — Laravel API

Laravel 12 API with Sanctum authentication, Socialite for OAuth (Google, Apple), and MySQL database.

## Running with Docker (Recommended)

From the project root:

```bash
docker compose up --build
```

The API will be available at `http://localhost:8000/api`. See the [root README](../README.md) for full Docker instructions.

### What the Docker entrypoint does

1. Runs `composer install` (dependencies cached in a named volume)
2. Copies `.env.example` to `.env` if `.env` doesn't exist
3. Patches `.env` DB settings to use Docker's MySQL (overrides any local SQLite config)
4. Generates `APP_KEY` if empty
5. Waits for MySQL to be ready (up to 30 attempts)
6. Runs `php artisan migrate --force`
7. Starts `php artisan serve --host=0.0.0.0 --port=8000`

### Running artisan commands in Docker

```bash
docker compose exec backend php artisan tinker
docker compose exec backend php artisan migrate:status
docker compose exec backend php artisan migrate:fresh --seed
```

## Running without Docker

### Prerequisites

- PHP 8.2+
- Composer 2.x
- MySQL 8.0+ (or SQLite for quick local dev)

### Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve --host=0.0.0.0
```

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | No | Register with email/password |
| POST | `/api/auth/login` | No | Login with email/password |
| POST | `/api/auth/social` | No | Login with social provider token |
| POST | `/api/auth/logout` | Yes | Logout (revoke token) |
| GET | `/api/user` | Yes | Get authenticated user |
| GET | `/api/health` | No | Health check |

## Key Files

| File | Description |
|------|-------------|
| `app/Http/Controllers/AuthController.php` | All auth logic (register, login, social, logout) |
| `app/Models/User.php` | User model with social provider fields + Sanctum tokens |
| `routes/api.php` | API route definitions |
| `config/services.php` | OAuth provider config (Google, Apple) |
| `config/cors.php` | CORS configuration for mobile requests |
| `Dockerfile` | PHP 8.2-cli image with extensions |
| `docker-entrypoint.sh` | Container startup script |

## Environment

The backend `.env.example` includes both SQLite (for quick local dev) and MySQL (for Docker) configurations. When running in Docker, the entrypoint automatically patches `.env` to use MySQL.

Key variables:

```env
DB_CONNECTION=sqlite          # Local dev (default)
# DB_CONNECTION=mysql         # Docker (set automatically by entrypoint)

SANCTUM_STATEFUL_DOMAINS=localhost,localhost:8000

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
APPLE_CLIENT_ID=
APPLE_CLIENT_SECRET=
```
