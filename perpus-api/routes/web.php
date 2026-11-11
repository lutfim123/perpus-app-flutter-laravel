<?php

use Illuminate\Support\Facades\Route;

// Halaman utama langsung diarahkan ke Swagger UI
Route::get('/', fn () => redirect('/api/documentation'));
