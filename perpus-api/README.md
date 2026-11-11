# Perpustakaan API: Laravel 12 + Sanctum + CRUD Buku + OpenAPI (Swagger)

Proyek contoh REST API untuk tutorial **"Laravel 12 REST API: Login, CRUD Buku & Dokumentasi OpenAPI Swagger"**.

- Laravel 12, PHP 8.2+ (diuji sintaksnya dengan PHP 8.3)
- Login berbasis token **Laravel Sanctum**
- CRUD **Buku** (paginasi, pencarian, validasi, API Resource)
- Dokumentasi interaktif **Swagger UI** dari PHP Attributes `#[OA\...]` (paket `darkaonline/l5-swagger`)
- Test otomatis (PHPUnit): 8 feature test + 1 unit test

## Persyaratan

- PHP 8.2 atau lebih baru dengan ekstensi `pdo_sqlite` (atau `pdo_mysql`), `mbstring`, `openssl`, `xml`, `curl`, `fileinfo`
- Composer 2
- Windows: Laragon / XAMPP dengan PHP 8.3 sudah cukup

## Instalasi cepat

Ekstrak ZIP, masuk ke folder `perpus-api`, lalu:

**Windows**

```bat
setup.bat
php artisan serve
```

**Linux / macOS**

```bash
bash setup.sh
php artisan serve
```

Buka **http://localhost:8000/api/documentation**

Login demo: `admin@example.com` / `password`, lalu salin token, klik tombol **Authorize**, dan tempel token tersebut (tanpa kata "Bearer").

## Instalasi manual

```bash
composer install
cp .env.example .env            # Windows: copy .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan l5-swagger:generate
php artisan serve
```

Atau cukup: `composer install && composer run setup`.

### Memakai MySQL

Buat database `perpus_api`, lalu ubah `.env`:

```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=perpus_api
DB_USERNAME=root
DB_PASSWORD=
```

Lalu jalankan `php artisan migrate:fresh --seed`.

## Endpoint

| Method    | Endpoint            | Fungsi                              | Login |
|-----------|---------------------|-------------------------------------|-------|
| POST      | /api/register       | Daftar akun, dapat token            | -     |
| POST      | /api/login          | Login, dapat token                  | -     |
| GET       | /api/me             | Profil user yang login              | ya    |
| POST      | /api/logout         | Hapus token aktif                   | ya    |
| GET       | /api/books          | Daftar buku (`?search=`, `?per_page=`, `?page=`) | ya |
| POST      | /api/books          | Tambah buku                         | ya    |
| GET       | /api/books/{book}   | Detail buku                         | ya    |
| PUT/PATCH | /api/books/{book}   | Ubah buku                           | ya    |
| DELETE    | /api/books/{book}   | Hapus buku                          | ya    |

## Struktur kode penting

```
app/Http/Controllers/Controller.php           # OA\Info, OA\Server, OA\SecurityScheme, OA\Tag
app/Http/Controllers/Api/AuthController.php   # register, login, me, logout + atribut OpenAPI
app/Http/Controllers/Api/BookController.php   # CRUD buku + atribut OpenAPI
app/Http/Requests/                            # validasi + OA\Schema request body
app/Http/Resources/                           # format JSON + OA\Schema response
app/Models/Book.php, User.php (HasApiTokens)
database/migrations, factories, seeders
routes/api.php
tests/Feature/AuthApiTest.php, BookApiTest.php
```

## Test

```bash
php artisan test
```

Test memakai SQLite in-memory, jadi data development tidak tersentuh.

## Konfigurasi Swagger (opsional)

L5-Swagger sudah berjalan dengan pengaturan bawaan. Untuk mengubah judul, URL, atau folder yang dipindai:

```bash
php artisan vendor:publish --provider="L5Swagger\L5SwaggerServiceProvider"
```

Ini membuat `config/l5-swagger.php`. Di produksi, set `L5_SWAGGER_GENERATE_ALWAYS=false` lalu jalankan `php artisan l5-swagger:generate` saat deploy.

## Troubleshooting

| Gejala | Solusi |
|---|---|
| `Required @OA\Info() not found` | `composer dump-autoload`, lalu `php artisan l5-swagger:generate` |
| `Undefined constant L5_SWAGGER_CONST_HOST` | Pastikan ada di `.env`, lalu `php artisan config:clear` |
| Swagger UI selalu 401 | Klik **Authorize** dan tempel token tanpa kata "Bearer" |
| Apache: token tidak terbaca | Pastikan `mod_rewrite` aktif dan `AllowOverride All` (lihat `public/.htaccess`) |
| `could not find driver` | Aktifkan ekstensi `pdo_sqlite` / `pdo_mysql` di `php.ini` |
