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
     * Display a listing of evaluations for the company's internships.
     */
    public function index()
    {
        $companyId = Auth::user()->company->id;

        $evaluations = CompanyEvaluation::with(['internship.student', 'internship.opportunity'])
            ->whereHas('internship', function ($query) use ($companyId) {
                $query->where('company_id', $companyId);
            })
            ->latest()
            ->get();

        return response()->json($evaluations);
    }

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

        // Check for existing evaluation and update instead of creating duplicate
        $existing = CompanyEvaluation::where('internship_id', $validated['internship_id'])->first();

        if ($existing) {
            $existing->update([
                'detailed_scores' => $validated['detailed_scores'],
                'total_score' => $validated['total_score'],
                'comments' => $validated['comments'] ?? $existing->comments,
                'evaluator_id' => Auth::id(),
            ]);

            $existing->load(['internship.student', 'internship.opportunity']);

            return response()->json([
                'message' => 'Evaluation updated successfully',
                'evaluation' => $existing
            ]);
        }

        $validated['evaluator_id'] = Auth::id();

        $evaluation = CompanyEvaluation::create($validated);
        $evaluation->load(['internship.student', 'internship.opportunity']);

        return response()->json([
            'message' => 'Evaluation submitted successfully',
            'evaluation' => $evaluation
        ], 201);
    }
}
