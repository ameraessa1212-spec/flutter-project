<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\DiscussionScheduleIndexRequest;
use App\Http\Resources\Mobile\DiscussionScheduleResource;
use App\Models\DiscussionSchedule;
use Illuminate\Http\JsonResponse;

class DiscussionScheduleController extends Controller
{
    public function index(DiscussionScheduleIndexRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $schedules = DiscussionSchedule::query()
            ->with('specialization')
            ->when($request->filled('specialization_id'), fn ($query) => $query->where('specialization_id', $request->integer('specialization_id')))
            ->when($request->filled('academic_term'), fn ($query) => $query->where('academic_term', $request->string('academic_term')))
            ->where('is_active', true)
            ->latest('published_at')
            ->paginate((int) ($validated['per_page'] ?? 15));

        return DiscussionScheduleResource::collection($schedules)->response();
    }

    public function show(DiscussionSchedule $schedule): JsonResponse
    {
        $schedule->load('specialization');

        return response()->json([
            'data' => DiscussionScheduleResource::make($schedule),
        ]);
    }
}
