<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Models\CompanyEvaluation;
use App\Models\Internship;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EvaluationController extends Controller
{
    /**
     * Store a newly created evaluation in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'internship_id' => 'required|exists:internships,id',
            'detailed_scores' => 'required|array',
            'total_score' => 'required|integer|min:0|max:100',
            'comments' => 'nullable|string',
        ]);

        $internship = Internship::findOrFail($validated['internship_id']);

        if ($internship->company_id !== Auth::user()->company->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated['evaluator_id'] = Auth::id();

        $evaluation = CompanyEvaluation::create($validated);

        return response()->json([
            'message' => 'Evaluation submitted successfully',
            'evaluation' => $evaluation
        ], 201);
    }
}
