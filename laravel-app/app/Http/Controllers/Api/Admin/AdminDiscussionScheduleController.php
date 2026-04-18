<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\DiscussionSchedule;
use App\Models\UserNotification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminDiscussionScheduleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = DiscussionSchedule::with('specialization');

        if ($specId = $request->input('specialization_id')) {
            $query->where('specialization_id', $specId);
        }

        $schedules = $query->latest()
            ->get()
            ->map(function ($schedule) {
                return [
                    'id' => $schedule->id,
                    'title' => $schedule->title,
                    'description' => $schedule->description,
                    'specialization' => $schedule->specialization?->name,
                    'academic_term' => $schedule->academic_term,
                    'image_url' => $schedule->schedule_image_path ? Storage::disk('public')->url($schedule->schedule_image_path) : null,
                    'file_url' => $schedule->schedule_file_path ? Storage::disk('public')->url($schedule->schedule_file_path) : null,
                    'is_active' => $schedule->is_active,
                    'published_at' => $schedule->published_at?->toISOString(),
                ];
            });

        return response()->json(['data' => $schedules]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'image' => ['required', 'image', 'max:5120'],
            'targets' => ['required', 'array', 'min:1'],
            'targets.*' => ['in:examiners,students'],
            'specialization_id' => ['nullable', 'exists:specializations,id'],
            'message' => ['nullable', 'string'],
            'title' => ['nullable', 'string'],
        ]);

        $imagePath = $request->file('image')->store('discussion-schedules', 'public');

        $schedule = DiscussionSchedule::create([
            'title' => $validated['title'] ?? 'جدول المناقشة',
            'description' => $validated['message'] ?? null,
            'specialization_id' => $validated['specialization_id'] ?? null,
            'schedule_image_path' => $imagePath,
            'is_active' => true,
            'published_at' => now(),
        ]);

        // Send notifications to targets
        $notifiedCount = 0;
        $specId = $validated['specialization_id'] ?? null;

        foreach ($validated['targets'] as $target) {
            $role = $target === 'examiners' ? 'examiner' : 'student';
            $query = User::where('role', $role)->where('status', 'active');

            // Filter student notifications by specialization if set
            if ($specId && $role === 'student') {
                $query->whereHas('studentProfile', fn ($q) => $q->where('specialization_id', $specId));
            }

            $users = $query->get();

            foreach ($users as $user) {
                UserNotification::create([
                    'user_id' => $user->id,
                    'title' => 'جدول مناقشة جديد',
                    'body' => $validated['message'] ?? 'تم نشر جدول مناقشة جديد.',
                    'type' => 'schedule',
                    'reference_type' => DiscussionSchedule::class,
                    'reference_id' => $schedule->id,
                ]);
                $notifiedCount++;
            }
        }

        return response()->json([
            'message' => "تم نشر الجدول وإرسال {$notifiedCount} إشعار بنجاح.",
            'data' => [
                'schedule_id' => $schedule->id,
                'notified' => $notifiedCount,
            ],
        ]);
    }
}
