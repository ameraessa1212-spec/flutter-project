<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Application;
use App\Models\Company;
use App\Models\Internship;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function stats(): JsonResponse
    {
        return response()->json([
            'data' => [
                'total_students' => User::where('role', 'student')->count(),
                'active_trainees' => Internship::where('status', 'active')->count(),
                'total_companies' => Company::where('is_active', true)->count(),
                'pending_requests' => Application::where('status', 'pending')->count(),
            ],
        ]);
    }

    public function chartData(): JsonResponse
    {
        $distribution = Internship::where('status', 'active')
            ->join('companies', 'internships.company_id', '=', 'companies.id')
            ->selectRaw('companies.name as company_name, count(*) as student_count')
            ->groupBy('companies.id', 'companies.name')
            ->orderByDesc('student_count')
            ->limit(10)
            ->get();

        return response()->json([
            'data' => [
                'labels' => $distribution->pluck('company_name'),
                'values' => $distribution->pluck('student_count'),
            ],
        ]);
    }

    public function alerts(): JsonResponse
    {
        $lateReports = Report::where('status', 'submitted')
            ->whereNull('reviewed_at')
            ->count();

        $pendingApplications = Application::where('status', 'pending')->count();

        $alerts = [];

        if ($lateReports > 0) {
            $alerts[] = [
                'type' => 'danger',
                'title' => 'تقارير متأخرة',
                'message' => "هناك {$lateReports} تقارير لم تقيم بعد.",
            ];
        }

        if ($pendingApplications > 0) {
            $alerts[] = [
                'type' => 'info',
                'title' => 'طلبات جديدة',
                'message' => "وصلتك {$pendingApplications} طلبات انضمام جديدة.",
            ];
        }

        return response()->json(['data' => $alerts]);
    }
}
