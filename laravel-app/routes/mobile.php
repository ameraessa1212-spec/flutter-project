<?php

use App\Http\Controllers\Api\Mobile\ApplicationController;
use App\Http\Controllers\Api\Mobile\AuthController;
use App\Http\Controllers\Api\Mobile\ChatThreadController;
use App\Http\Controllers\Api\Mobile\CompanyController;
use App\Http\Controllers\Api\Mobile\ContentController;
use App\Http\Controllers\Api\Mobile\DashboardController;
use App\Http\Controllers\Api\Mobile\DiscussionScheduleController;
use App\Http\Controllers\Api\Mobile\InternshipController;
use App\Http\Controllers\Api\Mobile\MessageController;
use App\Http\Controllers\Api\Mobile\NotificationController;
use App\Http\Controllers\Api\Mobile\OpportunityController;
use App\Http\Controllers\Api\Mobile\PasswordController;
use App\Http\Controllers\Api\Mobile\ProfileController;
use App\Http\Controllers\Api\Mobile\ReportController;
use App\Http\Controllers\Api\Mobile\SettingController;
use App\Http\Controllers\Api\Mobile\SpecializationController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->name('v1.')->group(function () {
    Route::get('specializations', [SpecializationController::class, 'index'])->name('specializations.index');

    Route::prefix('auth')->name('auth.')->group(function () {
        Route::post('register', [AuthController::class, 'register'])->name('register');
        Route::post('verify-otp', [AuthController::class, 'verifyOtp'])->name('verify-otp');
        Route::post('resend-otp', [AuthController::class, 'resendOtp'])->name('resend-otp');
        Route::post('login', [AuthController::class, 'login'])->name('login');

        Route::prefix('password')->name('password.')->group(function () {
            Route::post('forgot', [PasswordController::class, 'forgot'])->name('forgot');
            Route::post('verify', [PasswordController::class, 'verify'])->name('verify');
            Route::post('reset', [PasswordController::class, 'reset'])->name('reset');
        });
    });

    Route::prefix('content')->name('content.')->group(function () {
        Route::get('about-app', [ContentController::class, 'aboutApp'])->name('about-app');
        Route::get('terms', [ContentController::class, 'terms'])->name('terms');
        Route::get('privacy', [ContentController::class, 'privacy'])->name('privacy');
        Route::get('about-us', [ContentController::class, 'aboutUs'])->name('about-us');
    });


    Route::middleware('auth:sanctum')->group(function () {
        Route::prefix('auth')->name('auth.')->group(function () {
            Route::get('me', [AuthController::class, 'me'])->name('me');
            Route::post('logout', [AuthController::class, 'logout'])->name('logout');
            Route::post('logout-all', [AuthController::class, 'logoutAll'])->name('logout-all');
        });

        Route::prefix('profile')->name('profile.')->group(function () {
            Route::get('/', [ProfileController::class, 'show'])->name('show');
            Route::patch('/', [ProfileController::class, 'update'])->name('update');
            Route::patch('password', [ProfileController::class, 'updatePassword'])->name('password.update');
            Route::patch('fcm-token', [ProfileController::class, 'updateFcmToken'])->name('fcm-token.update');
            Route::post('avatar', [ProfileController::class, 'uploadAvatar'])->name('avatar.upload');
            Route::post('cv', [ProfileController::class, 'uploadCv'])->name('cv.upload');
        });

        Route::prefix('dashboard')->name('dashboard.')->group(function () {
            Route::get('home', [DashboardController::class, 'home'])->name('home');
        });

        Route::prefix('companies')->name('companies.')->group(function () {
            Route::get('/', [CompanyController::class, 'index'])->name('index');
            Route::get('{company}', [CompanyController::class, 'show'])->name('show');
        });

        Route::prefix('opportunities')->name('opportunities.')->group(function () {
            Route::get('/', [OpportunityController::class, 'index'])->name('index');
            Route::get('{opportunity}', [OpportunityController::class, 'show'])->name('show');
            Route::post('{opportunity}/applications', [ApplicationController::class, 'store'])->name('applications.store');
        });

        Route::prefix('applications')->name('applications.')->group(function () {
            Route::get('can-apply', [ApplicationController::class, 'canApply'])->name('can-apply');
            Route::get('/', [ApplicationController::class, 'index'])->name('index');
            Route::get('{application}', [ApplicationController::class, 'show'])->name('show');
            Route::delete('{application}', [ApplicationController::class, 'destroy'])->name('destroy');
        });

        Route::prefix('internships')->name('internships.')->group(function () {
            Route::get('/', [InternshipController::class, 'index'])->name('index');
            Route::get('current', [InternshipController::class, 'current'])->name('current');
            Route::get('{internship}', [InternshipController::class, 'show'])->name('show');
            Route::get('{internship}/timeline', [InternshipController::class, 'timeline'])->name('timeline');
            Route::get('{internship}/reports', [ReportController::class, 'index'])->name('reports.index');
            Route::post('{internship}/reports', [ReportController::class, 'store'])->name('reports.store');
        });

        Route::prefix('reports')->name('reports.')->group(function () {
            Route::get('{report}', [ReportController::class, 'show'])->name('show');
            Route::get('{report}/download', [ReportController::class, 'download'])->name('download');
            Route::delete('{report}', [ReportController::class, 'destroy'])->name('destroy');
        });

        Route::prefix('chat')->name('chat.')->group(function () {
            Route::get('threads', [ChatThreadController::class, 'index'])->name('threads.index');
            Route::get('threads/{thread}', [ChatThreadController::class, 'show'])->name('threads.show');
            Route::get('threads/{thread}/messages', [MessageController::class, 'index'])->name('messages.index');
            Route::post('threads/{thread}/messages', [MessageController::class, 'store'])->name('messages.store');
            Route::post('threads/{thread}/attachments', [MessageController::class, 'storeAttachment'])->name('messages.attachments.store');
            Route::post('threads/{thread}/read', [MessageController::class, 'markRead'])->name('messages.read');

            // --- Chatify Bridge Routes ---
            Route::get('contacts', [\App\Http\Controllers\Api\Mobile\MobileChatController::class, 'contacts']);
            Route::get('messages', [\App\Http\Controllers\Api\Mobile\MobileChatController::class, 'getMessages']);
            Route::post('messages', [\App\Http\Controllers\Api\Mobile\MobileChatController::class, 'sendMessage']);
        });

        Route::prefix('notifications')->name('notifications.')->group(function () {
            Route::get('/', [NotificationController::class, 'index'])->name('index');
            Route::get('unread-count', [NotificationController::class, 'unreadCount'])->name('unread-count');
            Route::patch('{notification}/read', [NotificationController::class, 'markRead'])->name('read');
            Route::patch('read-all', [NotificationController::class, 'markAllRead'])->name('read-all');
        });

        Route::prefix('discussion-schedules')->name('discussion-schedules.')->group(function () {
            Route::get('/', [DiscussionScheduleController::class, 'index'])->name('index');
            Route::get('{schedule}', [DiscussionScheduleController::class, 'show'])->name('show');
        });

        Route::prefix('settings')->name('settings.')->group(function () {
            Route::get('/', [SettingController::class, 'show'])->name('show');
            Route::patch('/', [SettingController::class, 'update'])->name('update');
        });
    });
});
