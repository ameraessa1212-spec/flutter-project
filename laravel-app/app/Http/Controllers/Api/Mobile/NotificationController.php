<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Resources\Mobile\NotificationResource;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $notifications = UserNotification::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate((int) $request->integer('per_page', 20));

        return NotificationResource::collection($notifications)->response();
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $count = UserNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'data' => [
                'unread_count' => $count,
            ],
        ]);
    }

    public function markRead(Request $request, UserNotification $notification): JsonResponse
    {
        $this->authorize('update', $notification);

        $notification->update([
            'is_read' => true,
            'read_at' => now(),
        ]);

        return response()->json([
            'message' => 'Notification marked as read.',
        ]);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        UserNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'message' => 'All notifications marked as read.',
        ]);
    }
}
