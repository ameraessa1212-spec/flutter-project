<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ExaminerDiscussion;
use App\Models\Internship;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EvaluationListController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Internship::with([
            'student.studentProfile.specialization',
            'company',
            'examinerDiscussions.examiner',
        ])->where('status', 'active');

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

        $internships = $query->latest()->get();

        $data = $internships->map(function ($internship) {
            $assignment = $internship->examinerDiscussions->first();

            return [
                'id' => $internship->id,
                'student_id' => $internship->student_id,
                'student_name' => $internship->student?->name,
                'student_number' => $internship->student?->studentProfile?->student_number,
                'specialization' => $internship->student?->studentProfile?->specialization?->name,
                'company_name' => $internship->company?->name,
                'assigned_examiner' => $assignment?->examiner?->name,
            ];
        });

        return response()->json(['data' => $data]);
    }

    public function sendToExaminer(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'student_ids' => ['required', 'array', 'min:1'],
            'student_ids.*' => ['exists:users,id'],
            'examiner_id' => ['required', 'exists:users,id'],
        ]);

        $created = 0;
        $skipped = [];

        foreach ($validated['student_ids'] as $studentId) {
            $internship = Internship::with('student')
                ->where('student_id', $studentId)
                ->where('status', 'active')
                ->first();

            if (! $internship) {
                continue;
            }

            $existing = ExaminerDiscussion::where('internship_id', $internship->id)
                ->where('student_id', $studentId)
                ->with('examiner')
                ->first();

            if ($existing) {
                $studentName = $internship->student?->name ?? $studentId;
                $examinerName = $existing->examiner?->name ?? 'ممتحن آخر';
                $skipped[] = "{$studentName} (معين للممتحن: {$examinerName})";
                continue;
            }

            ExaminerDiscussion::create([
                'internship_id' => $internship->id,
                'student_id' => $studentId,
                'examiner_id' => $validated['examiner_id'],
                'status' => 'scheduled',
            ]);

            $created++;
        }

        $message = "تم تحويل {$created} طالب إلى الممتحن بنجاح.";
        if (! empty($skipped)) {
            $message .= ' تم تخطي: ' . implode('، ', $skipped);
        }

        return response()->json([
            'message' => $message,
            'data' => ['assigned' => $created, 'skipped' => count($skipped)],
        ]);
    }
}
