<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome', [
        'supabaseApiUrl' => config('supabase.url'),
        'supabaseSchema' => env('DB_SCHEMA', 'laravel'),
    ]);
});
