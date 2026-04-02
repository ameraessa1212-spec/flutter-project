<?php

use App\Http\Controllers\Api\Admin\AuthController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\StudentController;
use App\Http\Controllers\Api\Admin\StudentEvaluationController;
use App\Http\Controllers\Api\Admin\StudentReportController;
use App\Http\Controllers\Api\Admin\StudentRequestController;
use App\Http\Controllers\Api\Admin\CompanyOfferController;
use App\Http\Controllers\Api\Admin\RegisteredCompanyController;
use App\Http\Controllers\Api\Admin\CompanyAccountController;
use App\Http\Controllers\Api\Admin\ExaminerController;
use App\Http\Controllers\Api\Admin\EvaluationListController;
use App\Http\Controllers\Api\Admin\EvaluationResultController;
use App\Http\Controllers\Api\Admin\AdminDiscussionScheduleController;
use App\Http\Controllers\Api\Admin\SystemReportController;
use App\Http\Controllers\Api\Admin\ChatController;
use App\Http\Controllers\Api\Admin\ExaminerDashboardController;
use App\Http\Controllers\Api\Admin\NotificationController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware(['auth:sanctum', 'admin.role:super_admin,operations,supervisor,examiner,content_manager,support'])->group(function () {
    // Auth
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Dashboard
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
    Route::get('/dashboard/chart-data', [DashboardController::class, 'chartData']);
    Route::get('/dashboard/alerts', [DashboardController::class, 'alerts']);

    // Students
    Route::get('/students', [StudentController::class, 'index']);
    Route::post('/students/upload', [StudentController::class, 'upload']);
    Route::get('/students/{user}', [StudentController::class, 'show']);
    Route::put('/students/{user}', [StudentController::class, 'update']);
    Route::put('/students/{user}/password', [StudentController::class, 'updatePassword']);
    Route::put('/students/{user}/toggle-status', [StudentController::class, 'toggleStatus']);

    // Student Requests (Applications)
    Route::get('/student-requests', [StudentRequestController::class, 'index']);
    Route::get('/student-requests/{application}', [StudentRequestController::class, 'show']);
    Route::put('/student-requests/{application}/status', [StudentRequestController::class, 'updateStatus']);

    // Student Reports
    Route::get('/student-reports', [StudentReportController::class, 'index']);
    Route::get('/student-reports/{report}', [StudentReportController::class, 'show']);
    Route::post('/student-reports/{report}/notify', [StudentReportController::class, 'notify']);

    // Student Evaluations
    Route::get('/student-evaluations', [StudentEvaluationController::class, 'index']);
    Route::get('/student-evaluations/{internship}', [StudentEvaluationController::class, 'show']);

    // Company Offers
    Route::get('/company-offers', [CompanyOfferController::class, 'index']);
    Route::put('/company-offers/{opportunity}/approve', [CompanyOfferController::class, 'approve']);
    Route::put('/company-offers/{opportunity}/reject', [CompanyOfferController::class, 'reject']);

    // Registered Companies
    Route::get('/registered-companies', [RegisteredCompanyController::class, 'index']);

    // Company Accounts
    Route::get('/company-accounts', [CompanyAccountController::class, 'index']);
    Route::put('/company-accounts/{company}/toggle-status', [CompanyAccountController::class, 'toggleStatus']);
    Route::put('/company-accounts/{company}/approve', [CompanyAccountController::class, 'approve']);
    Route::put('/company-accounts/{company}/reject', [CompanyAccountController::class, 'reject']);

    // Examiners
    Route::get('/examiners', [ExaminerController::class, 'index']);
    Route::post('/examiners', [ExaminerController::class, 'store']);
    Route::put('/examiners/{user}', [ExaminerController::class, 'update']);
    Route::delete('/examiners/{user}', [ExaminerController::class, 'destroy']);
    Route::put('/examiners/{user}/toggle-status', [ExaminerController::class, 'toggleStatus']);
    Route::get('/examiners/{examiner}/reports', [ExaminerController::class, 'reports']);
    Route::get('/examiner/students', [ExaminerController::class, 'students']);
    Route::post('/examiner/grades', [ExaminerController::class, 'storeGrade']);

    // Evaluation List
    Route::get('/evaluation-list', [EvaluationListController::class, 'index']);
    Route::post('/evaluation-list/send-to-examiner', [EvaluationListController::class, 'sendToExaminer']);

    // Evaluation Results
    Route::get('/evaluation-results', [EvaluationResultController::class, 'index']);

    // Discussion Schedule
    Route::get('/discussion-schedules', [AdminDiscussionScheduleController::class, 'index']);
    Route::post('/discussion-schedules', [AdminDiscussionScheduleController::class, 'store']);

    // System Reports
    Route::get('/system-reports', [SystemReportController::class, 'index']);

    // Chat
    Route::get('/chat/contacts', [ChatController::class, 'contacts']);
    Route::get('/chat/messages', [ChatController::class, 'messages']);
    Route::post('/chat/messages', [ChatController::class, 'send']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
    Route::patch('/notifications/read-all', [NotificationController::class, 'markAllRead']);

    // Examiner Dashboard
    Route::get('/examiner/dashboard', [ExaminerDashboardController::class, 'index']);

    // Specializations (shared lookup)
    Route::get('/specializations', function () {
        return response()->json([
            'data' => \App\Models\Specialization::where('is_active', true)->orderBy('name')->get(['id', 'name', 'code']),
        ]);
    });
});
