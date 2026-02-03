#!/bin/bash
set -e

echo "==> Installing npm dependencies..."
npm ci

# Copy .env.example to .env if .env does not exist
if [ ! -f .env ]; then
    echo "==> Creating .env from .env.example..."
    cp .env.example .env
fi

echo "==> Starting Expo Metro bundler on port 8081..."
export EXPO_NO_INTERACTIVE=1
exec npx expo start --port 8081
