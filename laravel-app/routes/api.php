<?php

use App\Http\Controllers\Api\CurrentUserController;
use App\Http\Controllers\Api\SupabaseStorageController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/supabase/health', function () {
    return response()->json([
        'supabase_url_configured' => filled(config('supabase.url')),
        'storage_bucket' => config('supabase.storage.bucket'),
        'db_connection' => config('database.default'),
        'db_schema' => config('database.connections.pgsql.search_path'),
    ]);
});

Route::middleware('auth:supabase')->group(function () {
    Route::get('/me', CurrentUserController::class);
    Route::post('/storage/upload', SupabaseStorageController::class);
});