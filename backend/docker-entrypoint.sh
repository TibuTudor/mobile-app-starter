#!/bin/bash
set -e

echo "==> Installing Composer dependencies..."
composer install --no-interaction --prefer-dist

# Copy .env.example to .env if .env does not exist
if [ ! -f .env ]; then
    echo "==> Creating .env from .env.example..."
    cp .env.example .env
fi

# Override DB settings in .env to match Docker Compose environment.
# The bind-mounted .env may have DB_CONNECTION=sqlite from local development.
# php artisan serve re-reads .env per request, bypassing shell env vars.
echo "==> Configuring .env for Docker (MySQL)..."
sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=${DB_CONNECTION:-mysql}/" .env
# Uncomment and set DB_HOST/DB_PORT/DB_DATABASE/DB_USERNAME/DB_PASSWORD if commented
sed -i "s/^#\s*DB_HOST=.*/DB_HOST=${DB_HOST:-db}/" .env
sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST:-db}/" .env
sed -i "s/^#\s*DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env
sed -i "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env
sed -i "s/^#\s*DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-laravel}/" .env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-laravel}/" .env
sed -i "s/^#\s*DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-laravel}/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-laravel}/" .env
sed -i "s/^#\s*DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-secret}/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-secret}/" .env

# Generate APP_KEY if it is empty
if grep -q "^APP_KEY=$" .env; then
    echo "==> Generating APP_KEY..."
    php artisan key:generate --force
fi

# Wait for MySQL to be ready
echo "==> Waiting for MySQL..."
MAX_ATTEMPTS=30
ATTEMPT=0
until php -r "
    try {
        new PDO(
            'mysql:host=' . getenv('DB_HOST') . ';port=' . (getenv('DB_PORT') ?: '3306'),
            getenv('DB_USERNAME'),
            getenv('DB_PASSWORD')
        );
        echo 'connected';
        exit(0);
    } catch (Exception \$e) {
        exit(1);
    }
" 2>/dev/null; do
    ATTEMPT=$((ATTEMPT + 1))
    if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
        echo "ERROR: MySQL not reachable after $MAX_ATTEMPTS attempts. Exiting."
        exit 1
    fi
    echo "    Attempt $ATTEMPT/$MAX_ATTEMPTS — waiting 2s..."
    sleep 2
done
echo "==> MySQL is ready."

echo "==> Running migrations..."
php artisan migrate --force

echo "==> Starting Laravel dev server on 0.0.0.0:8000..."
exec php artisan serve --host=0.0.0.0 --port=8000
