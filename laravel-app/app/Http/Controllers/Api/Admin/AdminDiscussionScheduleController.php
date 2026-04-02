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
        $schedules = DiscussionSchedule::with('specialization')
            ->latest()
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
            'specialization_filter' => ['nullable', 'string'],
            'message' => ['nullable', 'string'],
            'title' => ['nullable', 'string'],
        ]);

        $imagePath = $request->file('image')->store('discussion-schedules', 'public');

        $schedule = DiscussionSchedule::create([
            'title' => $validated['title'] ?? 'جدول المناقشة',
            'description' => $validated['message'] ?? null,
            'schedule_image_path' => $imagePath,
            'is_active' => true,
            'published_at' => now(),
        ]);

        // Send notifications to targets
        $notifiedCount = 0;
        foreach ($validated['targets'] as $target) {
            $role = $target === 'examiners' ? 'examiner' : 'student';
            $users = User::where('role', $role)->where('status', 'active')->get();

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
