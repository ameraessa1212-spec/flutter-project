<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Resources\Mobile\InternshipResource;
use App\Models\Internship;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InternshipController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $internships = Internship::query()
            ->with(['company', 'opportunity', 'supervisor'])
            ->where('student_id', $request->user()->id)
            ->latest()
            ->paginate((int) $request->integer('per_page', 15));

        return InternshipResource::collection($internships)->response();
    }

    public function current(Request $request): JsonResponse
    {
        $internship = Internship::query()
            ->with(['company', 'opportunity', 'supervisor'])
            ->where('student_id', $request->user()->id)
            ->where('status', 'active')
            ->latest('start_date')
            ->first();

        return response()->json([
            'data' => InternshipResource::make($internship),
        ]);
    }

    public function show(Request $request, Internship $internship): JsonResponse
    {
        $this->authorize('view', $internship);

        $internship->load(['company', 'opportunity', 'supervisor']);

        return response()->json([
            'data' => InternshipResource::make($internship),
        ]);
    }

    public function timeline(Request $request, Internship $internship): JsonResponse
    {
        $this->authorize('view', $internship);

        return response()->json([
            'data' => [
                [
                    'key' => 'application_accepted',
                    'status' => 'done',
                    'date' => optional($internship->created_at)->toDateString(),
                ],
                [
                    'key' => 'internship_started',
                    'status' => $internship->start_date ? 'done' : 'pending',
                    'date' => optional($internship->start_date)->toDateString(),
                ],
                [
                    'key' => 'report_due',
                    'status' => $internship->report_due_date ? 'upcoming' : 'pending',
                    'date' => optional($internship->report_due_date)->toDateString(),
                ],
                [
                    'key' => 'internship_completed',
                    'status' => $internship->status === 'completed' ? 'done' : 'pending',
                    'date' => optional($internship->end_date)->toDateString(),
                ],
            ],
        ]);
    }
}
