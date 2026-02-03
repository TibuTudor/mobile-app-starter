#!/bin/bash

# Laravel Backend Setup Script
# Run this script to set up the Laravel backend

set -e

echo "🚀 Setting up Laravel Backend..."

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    echo "❌ Composer is not installed. Please install it first."
    exit 1
fi

# Check if we're in the backend directory
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ Please run this script from the backend directory"
    exit 1
fi

# Create Laravel project if not exists
if [ ! -f "artisan" ]; then
    echo "📦 Creating Laravel project..."
    composer create-project laravel/laravel temp --prefer-dist
    mv temp/* temp/.* . 2>/dev/null || true
    rmdir temp
fi

# Install dependencies
echo "📦 Installing Sanctum and Socialite..."
composer require laravel/sanctum laravel/socialite

# Publish Sanctum
echo "📄 Publishing Sanctum configuration..."
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force

# Copy starter files
echo "📂 Copying starter files..."

# Create directories if they don't exist
mkdir -p app/Http/Controllers
mkdir -p database/migrations

# Copy files
cp starter-files/app/Http/Controllers/AuthController.php app/Http/Controllers/
cp starter-files/app/Models/User.php app/Models/
cp starter-files/routes/api.php routes/
cp starter-files/config/services.php config/
cp starter-files/config/cors.php config/

# Copy migration with timestamp
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cp starter-files/database/migrations/add_social_fields_to_users.php "database/migrations/${TIMESTAMP}_add_social_fields_to_users.php"

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate
fi

# Add OAuth config to .env
if ! grep -q "GOOGLE_CLIENT_ID" .env; then
    echo "" >> .env
    echo "# OAuth Configuration" >> .env
    echo "GOOGLE_CLIENT_ID=" >> .env
    echo "GOOGLE_CLIENT_SECRET=" >> .env
    echo "GOOGLE_REDIRECT_URI=http://localhost:8000/api/auth/google/callback" >> .env
    echo "" >> .env
    echo "APPLE_CLIENT_ID=" >> .env
    echo "APPLE_CLIENT_SECRET=" >> .env
    echo "APPLE_REDIRECT_URI=http://localhost:8000/api/auth/apple/callback" >> .env
fi

echo ""
echo "✅ Laravel backend setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure your database in .env"
echo "2. Add your OAuth credentials to .env"
echo "3. Run: php artisan migrate"
echo "4. Run: php artisan serve"
