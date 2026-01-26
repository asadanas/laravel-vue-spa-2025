#!/bin/sh
set -e

echo "Starting Laravel Entrypoint..."

# Wait for the database
echo "Waiting for database to be ready..."
until nc -z db 3306; do
  echo "Waiting for MySQL at db:3306..."
  sleep 3
done

echo "Database is ready."

# Clear old caches
echo "Clearing Laravel caches..."
php artisan optimize:clear || true

# Cache config, routes, views
echo "Caching config, routes, and views..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Run migrations if enabled
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "RUN_MIGRATIONS is set to true — checking for pending migrations..."
    if php artisan migrate:status | grep -q 'No'; then
        echo "No pending migrations."
    else
        echo "Running pending migrations..."
        if php artisan migrate --force; then
            echo "Migrations completed successfully."
        else
            echo "Migration failed! See logs below:"
            cat storage/logs/laravel.log || true
            exit 1
        fi
    fi
else
    echo "RUN_MIGRATIONS is not set to true — skipping migrations."
fi

echo "Starting PHP-FPM..."
exec php-fpm -F

