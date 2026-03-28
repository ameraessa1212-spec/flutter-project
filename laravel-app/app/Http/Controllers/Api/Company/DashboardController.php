<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Models\Application;
use App\Models\Internship;
use App\Models\InternshipOpportunity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    /**
     * Get dashboard statistics.
     */
    public function stats()
    {
        $companyId = Auth::user()->company->id;

        $stats = [
            'total_opportunities' => InternshipOpportunity::where('company_id', $companyId)->count(),
            'active_opportunities' => InternshipOpportunity::where('company_id', $companyId)->where('status', 'published')->count(),
            'total_applications' => Application::where('company_id', $companyId)->count(),
            'pending_applications' => Application::where('company_id', $companyId)->where('status', 'pending')->count(),
            'active_interns' => Internship::where('company_id', $companyId)->where('status', 'active')->count(),
        ];

        return response()->json($stats);
    }
}
