<?php

use App\Http\Controllers\Api\CurrentUserController;
use App\Http\Controllers\Api\Mobile\MobileChatController;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;

Broadcast::routes(['middleware' => ['auth:sanctum']]);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', CurrentUserController::class);
});

Route::prefix('mobile')->name('mobile.')->group(base_path('routes/mobile.php'));