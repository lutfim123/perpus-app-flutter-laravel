<?php

namespace App\Providers;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // Respons resource tetap dibungkus "data" (sesuai dokumentasi Swagger)
        JsonResource::wrap('data');
    }
}
