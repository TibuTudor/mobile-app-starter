# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A monorepo starter for a mobile app: a **Laravel 12 API** (`backend/`) and a **React Native / Expo app** (`mobile/`), orchestrated together by the root `docker-compose.yml`. Authentication (email/password + Google/Apple OAuth via Sanctum tokens) is already wired end-to-end.

### Live code vs. scaffolding — read this first

The project is **already built**. Two things exist only to regenerate it from a blank Laravel/Expo install and are NOT the running app:

- `backend/starter-files/`, `mobile/starter-files/` — templates copied into place by the setup scripts
- `backend/setup.sh`, `mobile/setup.sh` — one-time bootstrap scripts
- `backend/CLAUDE.md`, `mobile/CLAUDE.md` — setup-from-scratch instructions (kept for that purpose; this root file describes the live project)

**When changing behavior, edit the live code** — `backend/app/**`, `backend/routes/**`, `backend/config/**`, and `mobile/{app,services,store,types}/**`. Editing `starter-files/` has no runtime effect, and re-running `setup.sh` on the built project is unnecessary and risks overwriting work.

## Running the stack

`./start.sh` is the primary entry point. Physical devices and the Metro bundler need the host's **LAN IP**, not `localhost`, so a bare `docker compose up` against an empty `.env` produces a broken `APP_URL=http://:8000` and an unreachable Metro host.

```bash
cp .env.example .env      # first time only
./start.sh                # detects LAN IP, writes HOST_IP into .env + EXPO_PUBLIC_API_URL into mobile/.env, then docker compose up --build -d
```

Once `.env` has a valid `HOST_IP`, `docker compose up --build` works directly. Services (default host ports): Laravel API `8000`, MySQL `3307`→3306, phpMyAdmin `8090`, Expo Metro `8081`.

**Host ports are configurable via `.env` overrides** — `docker-compose.yml` uses `${VAR:-default}` interpolation, so setting `API_HOST_PORT` / `DB_HOST_PORT` / `PMA_HOST_PORT` / `METRO_HOST_PORT` remaps a service without editing compose (for when another local project holds a port). Two subtleties: (1) `API_HOST_PORT` also feeds `APP_URL`, `EXPO_PUBLIC_API_URL`, and `SANCTUM_STATEFUL_DOMAINS`, so it stays consistent everywhere; (2) `METRO_HOST_PORT` maps host==container and is passed to `expo start --port` via `RCT_METRO_PORT`, because the phone connects to the exact `exp://IP:<port>` the QR advertises. Container-internal ports never change.

## Commands

```bash
# Backend tests (run inside the container, or locally from backend/)
docker compose exec backend php artisan test
docker compose exec backend php artisan test --filter=SomeTest   # single test
composer test                                                    # local, from backend/

# Backend artisan / one-offs
docker compose exec backend php artisan <command>
composer dev            # local only: runs server + queue + pail logs + vite concurrently

# Mobile (from mobile/)
npx expo start          # or npm run android | ios | web
```

**No test or lint runner is wired for `mobile/`** — `package.json` only defines start/android/ios/web. `components/__tests__/` and `react-test-renderer` are leftover Expo-template files; `npm test` / `npm run lint` will fail. Automated tests live only in the backend (`backend/tests/`, PHPUnit).

## Architecture

### Config propagation (why the whole thing hangs together)
Root `.env` `HOST_IP` is the single source of truth for the network address. `docker-compose.yml` fans it out to:
- backend: `APP_URL`, `SANCTUM_STATEFUL_DOMAINS`
- mobile: `REACT_NATIVE_PACKAGER_HOSTNAME` (so the QR code points at the LAN IP) and `EXPO_PUBLIC_API_URL`

The backend entrypoint (`backend/docker-entrypoint.sh`) forces MySQL settings into `.env` at boot — the bind-mounted `.env` may carry `DB_CONNECTION=sqlite` from local dev, and `php artisan serve` re-reads `.env` per request, so shell env vars alone aren't enough. It also generates `APP_KEY` if empty and waits for MySQL before migrating.

### Auth flow (spans several files)
1. **Backend** — `backend/routes/api.php` maps `/api/auth/{register,login,social,logout}` and `/api/user` to `app/Http/Controllers/AuthController.php`. Register/login hash-check and issue a Sanctum token (`createToken(...)->plainTextToken`). `social` verifies a provider (Google/Apple) token via Socialite and upserts the user. Protected routes use the `auth:sanctum` middleware; the `User` model tracks social provider fields.
2. **Mobile transport** — `mobile/services/api.ts` is one axios instance. A request interceptor attaches `Bearer <token>`; a 401 response interceptor clears the token. Tokens are stored via a `tokenStorage` shim: `expo-secure-store` on native, `localStorage` on web (`Platform.OS === 'web'`).
3. **Mobile state** — `mobile/services/auth.ts` wraps the endpoints; `mobile/store/authStore.ts` (Zustand) holds `user`, `isAuthenticated`, `isInitialized`, and calls `initialize()` on load to restore the session.
4. **Route gating** — `mobile/app/_layout.tsx` uses expo-router segments to redirect: unauthenticated users into the `(auth)` group (`login`/`register`), authenticated users into `(tabs)`. Screens live under `mobile/app/(auth)/` and `mobile/app/(tabs)/`.

## Gotchas
- The `mobile/app/(tabs)/two.tsx` screen is unmodified Expo-template boilerplate; `profile.tsx` is the real authenticated screen.
- OAuth requires real client IDs in `mobile/.env` (`EXPO_PUBLIC_GOOGLE_*`) and backend `services.php`; social login needs a development build (not Expo Go) for full functionality.
- Web is a supported target: besides the `localStorage` token fallback, `Alert.alert` should fall back to `window.alert`.