<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Resources\Mobile\InternshipOpportunityResource;
use App\Http\Resources\Mobile\InternshipResource;
use App\Models\Application;
use App\Models\DashboardContent;
use App\Models\Internship;
use App\Models\InternshipOpportunity;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;

class DashboardController extends Controller
{
    public function home(Request $request): JsonResponse
    {
        $user = $request->user();

        $applicationsCount = Application::query()
            ->where('student_id', $user->id)
            ->count();

        $unreadNotificationsCount = UserNotification::query()
            ->where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        $currentInternship = Internship::query()
            ->with(['company', 'opportunity', 'supervisor'])
            ->where('student_id', $user->id)
            ->where('status', 'active')
            ->latest('start_date')
            ->first();

        $featuredOpportunities = InternshipOpportunity::query()
            ->with(['company', 'specialization'])
            ->where('is_available', true)
            ->where('status', 'published')
            ->latest()
            ->limit(6)
            ->get();

        $sliderItems = DashboardContent::query()
            ->where('type', 'slider')
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        $tipCards = DashboardContent::query()
            ->where('type', 'tip')
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        $announcements = DashboardContent::query()
            ->where('type', 'announcement')
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        $unreadMessagesCount = \App\Models\Message::query()
            ->whereHas('thread', function ($q) use ($user) {
                $q->where('student_id', $user->id);
            })
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'data' => [
                'applications_count' => $applicationsCount,
                'unread_notifications_count' => $unreadNotificationsCount,
                'unread_messages_count' => $unreadMessagesCount,
                'current_internship' => $currentInternship
                    ? InternshipResource::make($currentInternship)->resolve()
                    : null,
                'featured_opportunities' => InternshipOpportunityResource::collection($featuredOpportunities)->resolve(),
                'slider_items' => $this->mapDashboardContentItems($sliderItems),
                'tip_cards' => $this->mapDashboardContentItems($tipCards),
                'announcements' => $this->mapDashboardContentItems($announcements),
            ],
        ]);

    }

    private function mapDashboardContentItems(Collection $items): array
    {
        return $items->map(function (DashboardContent $item): array {
            return [
                'title' => $item->title,
                'subtitle' => $item->subtitle,
                'image_asset' => $item->image_asset,
                'image_url' => $item->image_path ? url(Storage::url($item->image_path)) : null,
                'icon_key' => $item->icon_key,
                'badge' => $item->badge,
            ];
        })->values()->all();
    }
}