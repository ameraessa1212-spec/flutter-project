<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\Admin\AdminApplicationResource;
use App\Models\Application;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentRequestController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Application::with([
            'student.studentProfile.specialization',
            'company',
            'opportunity',
        ]);

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('full_name_snapshot', 'like', "%{$search}%")
                    ->orWhereHas('student', function ($q) use ($search) {
                        $q->where('name', 'like', "%{$search}%");
                    });
            });
        }

        $applications = $query->latest('submitted_at')->paginate($request->input('per_page', 20));

        return response()->json([
            'data' => AdminApplicationResource::collection($applications),
            'meta' => [
                'current_page' => $applications->currentPage(),
                'last_page' => $applications->lastPage(),
                'total' => $applications->total(),
            ],
        ]);
    }

    public function show(Application $application): JsonResponse
    {
        $application->load([
            'student.studentProfile.specialization',
            'company',
            'opportunity',
        ]);

        return response()->json([
            'data' => AdminApplicationResource::make($application),
        ]);
    }

    public function updateStatus(Request $request, Application $application): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:pending,approved,rejected,under_review'],
            'review_notes' => ['nullable', 'string'],
        ]);

        $application->update([
            'status' => $validated['status'],
            'reviewed_at' => now(),
            'reviewed_by' => $request->user()->id,
            'review_notes' => $validated['review_notes'] ?? null,
        ]);

        return response()->json([
            'message' => 'تم تحديث حالة الطلب بنجاح.',
            'data' => AdminApplicationResource::make($application->fresh()),
        ]);
    }
}
