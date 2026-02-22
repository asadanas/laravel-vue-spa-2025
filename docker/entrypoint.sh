#!/bin/sh
set -eu

echo "Starting Laravel Entrypoint..."

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"

echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."

i=0
until nc -z "$DB_HOST" "$DB_PORT" >/dev/null 2>&1; do
  i=$((i+1))
  echo "Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."
  sleep 3
  if [ "$i" -ge 40 ]; then
    echo "ERROR: Database not reachable at ${DB_HOST}:${DB_PORT} after 120 seconds."
    exit 1
  fi
done

echo "Database port is reachable."

echo "Clearing Laravel caches..."
php artisan optimize:clear || true

echo "Caching config, routes, and views..."
php artisan config:cache
php artisan route:cache || true
php artisan view:cache || true

if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
  echo "RUN_MIGRATIONS=true — running migrations..."
  php artisan migrate --force
else
  echo "RUN_MIGRATIONS is not true — skipping migrations."
fi

echo "Starting PHP-FPM..."
exec php-fpm -F

