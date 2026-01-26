#!/bin/sh
set -e

echo "Starting Laravel Entrypoint..."

# Read DB host/port from environment (Kubernetes injects these)
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"

# Wait for the database (with timeout)
echo "Waiting for database to be ready at ${DB_HOST}:${DB_PORT}..."

i=0
until nc -z "$DB_HOST" "$DB_PORT"; do
  i=$((i+1))
  echo "Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."
  sleep 3

  # Timeout after 120 seconds (40 * 3s)
  if [ "$i" -ge 40 ]; then
    echo "ERROR: Database not reachable at ${DB_HOST}:${DB_PORT} after 120 seconds."
    exit 1
  fi
done

echo "Database is ready."

# Clear old caches
echo "Clearing Laravel caches..."
php artisan optimize:clear || true

# Cache config, routes, and views
# Important: this is OK only if env vars are already injected (they are in K8s)
echo "Caching config, routes, and views..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Migrations: In Kubernetes production, prefer running migrations via a Job/Helm hook.
# Keep this OFF by default. If you still want it, set RUN_MIGRATIONS=true.
if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
  echo "RUN_MIGRATIONS is set to true — running migrations..."
  if php artisan migrate --force; then
    echo "Migrations completed successfully."
  else
    echo "Migration failed! Showing Laravel log (if available):"
    cat storage/logs/laravel.log || true
    exit 1
  fi
else
  echo "RUN_MIGRATIONS is not true — skipping migrations."
fi

echo "Starting PHP-FPM & Nginx..."

# Start PHP-FPM in background
php-fpm &

# Start nginx in foreground
exec nginx -g "daemon off;"

