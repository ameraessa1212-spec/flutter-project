<?php

use App\Http\Controllers\Api\CurrentUserController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->get('/me', CurrentUserController::class);

Route::prefix('mobile')->name('mobile.')->group(base_path('routes/mobile.php'));