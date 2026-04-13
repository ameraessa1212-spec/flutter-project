<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\DiscussionEvaluation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EvaluationResultController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = DiscussionEvaluation::with([
            'student.studentProfile.specialization',
            'examiner',
            'internship.company',
        ])->whereNotNull('submitted_at');

        if ($search = $request->input('search')) {
            $query->whereHas('student', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%");
            });
        }

        if ($specId = $request->input('specialization_id')) {
            $query->whereHas('student.studentProfile', function ($q) use ($specId) {
                $q->where('specialization_id', $specId);
            });
        }

        $evaluations = $query->latest('submitted_at')->get();

        $data = $evaluations->map(function ($eval) {
            return [
                'id' => $eval->id,
                'student_name' => $eval->student?->name,
                'student_number' => $eval->student?->studentProfile?->student_number,
                'specialization' => $eval->student?->studentProfile?->specialization?->name,
                'examiner_name' => $eval->examiner?->name,
                'company_name' => $eval->internship?->company?->name,
                'total_score' => $eval->total_score,
                'rubric_scores' => $eval->rubric_scores,
                'decision' => $eval->decision,
                'notes' => $eval->notes,
                'submitted_at' => $eval->submitted_at?->toISOString(),
            ];
        });

        return response()->json(['data' => $data]);
    }
}
