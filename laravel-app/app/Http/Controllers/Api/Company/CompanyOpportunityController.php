<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Http\Requests\Company\StoreOpportunityRequest;
use App\Models\InternshipOpportunity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompanyOpportunityController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $company = $user->company;

        if (!$company) {
            return response()->json([
                'success' => false,
                'message' => 'Company profile not found.',
            ], 404);
        }

        $opportunities = InternshipOpportunity::with('specialization')
            ->where('company_id', $company->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'opportunities' => $opportunities,
            ],
        ]);
    }

    public function store(StoreOpportunityRequest $request): JsonResponse
    {
        $user = $request->user();
        $company = $user->company;

        if (!$company) {
            return response()->json([
                'success' => false,
                'message' => 'Company profile not found.',
            ], 404);
        }

        $validated = $request->validated();
        $validated['company_id'] = $company->id;
        $validated['status'] = 'draft'; // Pending admin approval to publish
        $validated['is_available'] = false; // Admin must make it available

        $opportunity = InternshipOpportunity::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Opportunity created successfully. Awaiting admin approval.',
            'data' => [
                'opportunity' => $opportunity,
            ],
        ], 201);
    }
}

