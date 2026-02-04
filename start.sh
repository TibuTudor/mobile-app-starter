#!/usr/bin/env bash
set -euo pipefail

# ── 1. Detect LAN IP ───────────────────────────────────────────────
if command -v ipconfig &>/dev/null; then
  # macOS
  IP=$(ipconfig getifaddr en0 2>/dev/null || true)
fi

if [ -z "${IP:-}" ]; then
  # Linux / fallback
  IP=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
fi

if [ -z "${IP:-}" ]; then
  echo "ERROR: Could not detect LAN IP. Are you connected to a network?"
  exit 1
fi

echo "Detected LAN IP: $IP"

# ── 2. Update root .env ────────────────────────────────────────────
if [ ! -f .env ]; then
  echo "ERROR: .env file not found in project root."
  echo "Copy .env.example to .env first."
  exit 1
fi

sed -i.bak "s/^HOST_IP=.*/HOST_IP=$IP/" .env && rm -f .env.bak
echo "Updated .env -> HOST_IP=$IP"

# ── 3. Update mobile/.env ──────────────────────────────────────────
if [ -f mobile/.env ]; then
  sed -i.bak "s|^EXPO_PUBLIC_API_URL=.*|EXPO_PUBLIC_API_URL=http://$IP:8000/api|" mobile/.env && rm -f mobile/.env.bak
  echo "Updated mobile/.env -> EXPO_PUBLIC_API_URL=http://$IP:8000/api"
fi

# ── 4. Start Docker ────────────────────────────────────────────────
echo ""
echo "Starting Docker containers..."
docker compose up --build -d

# ── 5. Wait for Metro ──────────────────────────────────────────────
echo ""
echo "Waiting for Metro bundler to start..."

MAX_WAIT=120
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
  if docker compose logs mobile 2>&1 | grep -q "Metro waiting on"; then
    echo "Metro is ready!"
    break
  fi
  sleep 3
  ELAPSED=$((ELAPSED + 3))
  printf "."
done

echo ""

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo "WARNING: Timed out waiting for Metro. Check logs with: docker compose logs mobile"
fi

# ── 6. Display connection info ──────────────────────────────────────
echo ""
echo "================================================"
echo "  All services are running!"
echo "================================================"
echo ""
echo "  Backend API:   http://$IP:8000"
echo "  phpMyAdmin:    http://$IP:8090"
echo "  Metro bundler: http://$IP:8081"
echo "  Expo URL:      exp://$IP:8081"
echo ""
echo "  Scan the QR code below with Expo Go:"
echo ""

# Show the QR code from Metro logs
docker compose logs mobile 2>&1 | sed -n '/█/,/█/p' | tail -20

echo ""
echo "  Or open Expo Go and enter: exp://$IP:8081"
echo "================================================"
