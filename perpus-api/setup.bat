@echo off
REM Setup Perpustakaan API (Windows / Laragon / XAMPP)
cd /d "%~dp0"

echo ==^> 1. composer install
call composer install || goto :error

echo ==^> 2. Menyiapkan .env
if not exist .env copy .env.example .env >nul
if not exist database\database.sqlite type nul > database\database.sqlite

echo ==^> 3. APP_KEY
call php artisan key:generate || goto :error

echo ==^> 4. Migrasi + data contoh
call php artisan migrate:fresh --seed --force || goto :error

echo ==^> 5. Generate dokumentasi OpenAPI
call php artisan l5-swagger:generate || goto :error

echo.
echo Selesai! Jalankan:  php artisan serve
echo Buka  http://localhost:8000/api/documentation
echo Login demo: admin@example.com / password
goto :eof

:error
echo Terjadi error. Periksa pesan di atas.
exit /b 1
