<?php

use App\Http\Controllers\Api\CurrentUserController;
use App\Http\Controllers\Api\Mobile\MobileChatController;
use App\Http\Controllers\Api\Company\CompanyAuthController;
use App\Http\Controllers\Api\Company\ApplicationController;
use App\Http\Controllers\Api\Company\DashboardController;
use App\Http\Controllers\Api\Company\EvaluationController;
use App\Http\Controllers\Api\Company\InternshipController;
use App\Http\Controllers\Api\Company\OpportunityController;
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
        // Dashboard
        Route::get('/dashboard/stats', [DashboardController::class, 'stats']);

        // Opportunities
        Route::apiResource('opportunities', OpportunityController::class)->only(['index', 'store', 'show']);

        // Applications (Student Requests)
        Route::apiResource('requests', ApplicationController::class)->parameters(['requests' => 'application'])->only(['index', 'show']);
        Route::put('/requests/{application}/status', [ApplicationController::class, 'updateStatus']);

        // Internships (Active Students)
        Route::apiResource('internships', InternshipController::class)->only(['index', 'show']);

        // Evaluations
        Route::post('/evaluations', [EvaluationController::class, 'store']);
    });
});

Route::prefix('mobile')->name('mobile.')->group(base_path('routes/mobile.php'));