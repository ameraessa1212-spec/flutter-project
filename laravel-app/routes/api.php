<?php

use App\Http\Controllers\Api\CurrentUserController;
use App\Http\Controllers\Api\Mobile\MobileChatController;
use App\Http\Controllers\Api\Company\CompanyAuthController;
use App\Http\Controllers\Api\Company\CompanyDashboardController;
use App\Http\Controllers\Api\Company\CompanyOpportunityController;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;

Broadcast::routes(['middleware' => ['auth:sanctum']]);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', CurrentUserController::class);
});

// Company API Routes
Route::prefix('company')->name('company.')->group(function () {
    Route::post('/register', [CompanyAuthController::class, 'register']);
    Route::post('/login', [CompanyAuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/dashboard/students', [CompanyDashboardController::class, 'getStudents']);
        Route::get('/opportunities', [CompanyOpportunityController::class, 'index']);
        Route::post('/opportunities', [CompanyOpportunityController::class, 'store']);
    });
});

Route::prefix('mobile')->name('mobile.')->group(base_path('routes/mobile.php'));