<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Internship;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentEvaluationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Internship::with([
            'student.studentProfile.specialization',
            'company',
            'companyEvaluation',
            'discussionEvaluations',
        ]);

        if ($search = $request->input('search')) {
            $query->whereHas('student', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%");
            });
        }

        if ($specialization = $request->input('specialization_id')) {
            $query->whereHas('student.studentProfile', function ($q) use ($specialization) {
                $q->where('specialization_id', $specialization);
            });
        }

        $internships = $query->latest()->paginate($request->input('per_page', 20));

        $data = $internships->map(function ($internship) {
            $companyScore = $internship->companyEvaluation?->total_score ?? 0;
            $examinerScore = $internship->discussionEvaluations->avg('total_score') ?? 0;

            // Company weight 30%, Examiner weight 70%
            $companyWeighted = $companyScore * 0.3;
            $examinerWeighted = $examinerScore * 0.7;
            $finalScore = $companyWeighted + $examinerWeighted;

            return [
                'id' => $internship->id,
                'student' => [
                    'id' => $internship->student->id,
                    'name' => $internship->student->name,
                    'student_number' => $internship->student->studentProfile?->student_number,
                ],
                'company' => [
                    'id' => $internship->company->id,
                    'name' => $internship->company->name,
                ],
                'company_score' => round($companyScore, 1),
                'company_weighted' => round($companyWeighted, 1),
                'examiner_score' => round($examinerScore, 1),
                'examiner_weighted' => round($examinerWeighted, 1),
                'final_score' => round($finalScore, 1),
                'final_percentage' => round($finalScore, 0),
            ];
        });

        return response()->json([
            'data' => $data,
            'meta' => [
                'current_page' => $internships->currentPage(),
                'last_page' => $internships->lastPage(),
                'total' => $internships->total(),
            ],
        ]);
    }

    public function show(Internship $internship): JsonResponse
    {
        $internship->load([
            'student.studentProfile.specialization',
            'company',
            'companyEvaluation.evaluator',
            'discussionEvaluations.examiner',
        ]);

        $companyEval = $internship->companyEvaluation;
        $examinerEvals = $internship->discussionEvaluations;
        $companyScore = $companyEval?->total_score ?? 0;
        $examinerScore = $examinerEvals->avg('total_score') ?? 0;

        return response()->json([
            'data' => [
                'id' => $internship->id,
                'student' => [
                    'id' => $internship->student->id,
                    'name' => $internship->student->name,
                    'student_number' => $internship->student->studentProfile?->student_number,
                    'specialization' => $internship->student->studentProfile?->specialization?->name,
                ],
                'company' => [
                    'id' => $internship->company->id,
                    'name' => $internship->company->name,
                ],
                'company_evaluation' => $companyEval ? [
                    'total_score' => $companyEval->total_score,
                    'detailed_scores' => $companyEval->detailed_scores,
                    'comments' => $companyEval->comments,
                    'evaluator_name' => $companyEval->evaluator?->name,
                    'created_at' => $companyEval->created_at?->toISOString(),
                ] : null,
                'examiner_evaluations' => $examinerEvals->map(fn($eval) => [
                    'id' => $eval->id,
                    'examiner_name' => $eval->examiner?->name,
                    'rubric_scores' => $eval->rubric_scores,
                    'total_score' => $eval->total_score,
                    'decision' => $eval->decision,
                    'notes' => $eval->notes,
                    'submitted_at' => $eval->submitted_at?->toISOString(),
                ]),
                'company_score' => round($companyScore, 1),
                'company_weighted' => round($companyScore * 0.3, 1),
                'examiner_score' => round($examinerScore, 1),
                'examiner_weighted' => round($examinerScore * 0.7, 1),
                'final_score' => round($companyScore * 0.3 + $examinerScore * 0.7, 1),
                'final_percentage' => round($companyScore * 0.3 + $examinerScore * 0.7, 0),
            ],
        ]);
    }
}
