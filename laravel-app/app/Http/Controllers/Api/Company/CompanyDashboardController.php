<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Models\Internship;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompanyDashboardController extends Controller
{
    public function getStudents(Request $request): JsonResponse
    {
        $user = $request->user();
        $company = $user->company;

        if (!$company) {
            return response()->json([
                'success' => false,
                'message' => 'Company profile not found.',
            ], 404);
        }

        // Fetch students currently interning or applied to this company
        $internships = Internship::with(['student.user', 'opportunity'])
            ->where('company_id', $company->id)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'students' => $internships,
            ],
        ]);
    }
}

