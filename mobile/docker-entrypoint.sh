#!/bin/bash
set -e

echo "==> Installing npm dependencies..."
npm ci

# Copy .env.example to .env if .env does not exist
if [ ! -f .env ]; then
    echo "==> Creating .env from .env.example..."
    cp .env.example .env
fi

# Patch EXPO_PUBLIC_API_URL with the value from docker-compose environment
if [ -n "${EXPO_PUBLIC_API_URL:-}" ]; then
    echo "==> Setting EXPO_PUBLIC_API_URL=$EXPO_PUBLIC_API_URL in .env"
    sed -i "s|^EXPO_PUBLIC_API_URL=.*|EXPO_PUBLIC_API_URL=$EXPO_PUBLIC_API_URL|" .env
fi

echo "==> Starting Expo Metro bundler on port 8081..."
exec npx expo start --port 8081
