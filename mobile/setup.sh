#!/bin/bash

# React Native (Expo) Mobile App Setup Script
# Run this script to set up the mobile app

set -e

echo "🚀 Setting up React Native Mobile App..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install Node.js first."
    exit 1
fi

# Check if we're in the mobile directory
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ Please run this script from the mobile directory"
    exit 1
fi

# Create Expo project if not exists
if [ ! -f "package.json" ]; then
    echo "📦 Creating Expo project..."
    npx create-expo-app@latest temp --template tabs
    mv temp/* temp/.* . 2>/dev/null || true
    rmdir temp
fi

# Install dependencies
echo "📦 Installing dependencies..."
npx expo install expo-auth-session expo-web-browser expo-crypto expo-secure-store
npm install axios zustand

# Create directories
echo "📂 Creating directories..."
mkdir -p app/\(auth\)
mkdir -p services
mkdir -p store
mkdir -p types

# Copy starter files
echo "📂 Copying starter files..."

cp starter-files/app/\(auth\)/login.tsx app/\(auth\)/
cp starter-files/app/\(auth\)/register.tsx app/\(auth\)/
cp starter-files/app/\(auth\)/_layout.tsx app/\(auth\)/
cp starter-files/app/_layout.tsx app/
cp starter-files/services/api.ts services/
cp starter-files/services/auth.ts services/
cp starter-files/store/authStore.ts store/
cp starter-files/types/auth.ts types/

# Create profile tab if tabs directory exists
if [ -d "app/(tabs)" ]; then
    cp starter-files/app/\(tabs\)/profile.tsx app/\(tabs\)/
fi

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📄 Creating .env file..."
    cat > .env << 'EOF'
EXPO_PUBLIC_API_URL=http://localhost:8000/api
EXPO_PUBLIC_GOOGLE_CLIENT_ID=your_google_web_client_id
EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id
EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID=your_google_android_client_id
EOF
fi

# Update app.json with scheme
if [ -f "app.json" ]; then
    echo "📄 Updating app.json..."
    # Use node to update app.json
    node -e "
    const fs = require('fs');
    const config = JSON.parse(fs.readFileSync('app.json', 'utf8'));
    config.expo.scheme = config.expo.scheme || 'myapp';
    config.expo.ios = config.expo.ios || {};
    config.expo.ios.usesAppleSignIn = true;
    fs.writeFileSync('app.json', JSON.stringify(config, null, 2));
    "
fi

echo ""
echo "✅ Mobile app setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your API URL and OAuth client IDs"
echo "2. Run: npx expo start"
echo "3. Scan QR code with Expo Go app"
