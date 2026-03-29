<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\DiscussionEvaluation;
use App\Models\ExaminerDiscussion;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExaminerDashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $examinerId = $request->user()->id;

        $evaluatedCount = DiscussionEvaluation::where('examiner_id', $examinerId)->count();

        $pendingReports = ExaminerDiscussion::where('examiner_id', $examinerId)
            ->whereDoesntHave('evaluation')
            ->count();

        $avgScore = DiscussionEvaluation::where('examiner_id', $examinerId)
            ->avg('total_score');

        $alerts = UserNotification::where('user_id', $examinerId)
            ->where('is_read', false)
            ->latest()
            ->limit(5)
            ->get()
            ->map(function ($n) {
                return [
                    'id' => $n->id,
                    'title' => $n->title,
                    'body' => $n->body,
                    'type' => $n->type,
                    'created_at' => $n->created_at?->toISOString(),
                ];
            });

        $todayDiscussions = ExaminerDiscussion::where('examiner_id', $examinerId)
            ->where('status', 'scheduled')
            ->whereDate('scheduled_at', today())
            ->with('student')
            ->orderBy('scheduled_at')
            ->get()
            ->map(function ($d) {
                return [
                    'id' => $d->id,
                    'student_name' => $d->student?->name,
                    'time' => $d->scheduled_at?->format('h:i A'),
                    'location' => $d->location,
                    'status' => $d->status,
                    'is_urgent' => $d->is_urgent,
                ];
            });

        $upcomingDiscussions = ExaminerDiscussion::where('examiner_id', $examinerId)
            ->where('status', 'scheduled')
            ->where('scheduled_at', '>', now())
            ->with('student')
            ->orderBy('scheduled_at')
            ->limit(10)
            ->get()
            ->map(function ($d) {
                return [
                    'id' => $d->id,
                    'student_name' => $d->student?->name,
                    'time' => $d->scheduled_at?->format('h:i A'),
                    'date' => $d->scheduled_at?->toDateString(),
                    'location' => $d->location,
                ];
            });

        return response()->json([
            'data' => [
                'evaluated_count' => $evaluatedCount,
                'pending_reports' => $pendingReports,
                'average_score' => $avgScore ? round($avgScore, 0) . '%' : '0%',
                'alerts' => $alerts,
                'today_discussions' => $todayDiscussions,
                'upcoming_discussions' => $upcomingDiscussions,
            ],
        ]);
    }
}
