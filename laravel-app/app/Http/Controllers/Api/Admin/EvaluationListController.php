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
        ])->where('status', 'active');

        if ($search = $request->input('search')) {
            $query->whereHas('student', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%");
            });
        }

        if ($specialization = $request->input('specialization')) {
            $query->whereHas('student.studentProfile.specialization', function ($q) use ($specialization) {
                $q->where('name', 'like', "%{$specialization}%");
            });
        }

        $internships = $query->latest()->get();

        $data = $internships->map(function ($internship) {
            return [
                'id' => $internship->id,
                'student_id' => $internship->student_id,
                'student_name' => $internship->student?->name,
                'student_number' => $internship->student?->studentProfile?->student_number,
                'specialization' => $internship->student?->studentProfile?->specialization?->name,
                'company_name' => $internship->company?->name,
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
        foreach ($validated['student_ids'] as $studentId) {
            $internship = Internship::where('student_id', $studentId)
                ->where('status', 'active')
                ->first();

            if (! $internship) {
                continue;
            }

            $exists = ExaminerDiscussion::where('internship_id', $internship->id)
                ->where('student_id', $studentId)
                ->where('examiner_id', $validated['examiner_id'])
                ->exists();

            if ($exists) {
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

        return response()->json([
            'message' => "تم تحويل {$created} طالب إلى الممتحن بنجاح.",
            'data' => ['assigned' => $created],
        ]);
    }
}
