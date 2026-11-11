#!/usr/bin/env bash
# Setup Perpustakaan API (Linux / macOS)
set -e
cd "$(dirname "$0")"

echo "==> 1. composer install"
composer install

echo "==> 2. Menyiapkan .env"
[ -f .env ] || cp .env.example .env
[ -f database/database.sqlite ] || touch database/database.sqlite

echo "==> 3. APP_KEY"
php artisan key:generate

echo "==> 4. Migrasi + data contoh"
php artisan migrate:fresh --seed --force

echo "==> 5. Generate dokumentasi OpenAPI"
php artisan l5-swagger:generate

echo ""
echo "Selesai! Jalankan:  php artisan serve"
echo "Buka  http://localhost:8000/api/documentation"
echo "Login demo: admin@example.com / password"
