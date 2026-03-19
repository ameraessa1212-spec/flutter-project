<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\StoreReportRequest;
use App\Http\Resources\Mobile\ReportResource;
use App\Models\Internship;
use App\Models\Report;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request, Internship $internship): JsonResponse
    {
        $this->authorize('view', $internship);

        $reports = Report::query()
            ->where('internship_id', $internship->id)
            ->latest()
            ->get();

        return response()->json([
            'data' => ReportResource::collection($reports),
        ]);
    }

    public function store(StoreReportRequest $request, Internship $internship): JsonResponse
    {
        $this->authorize('view', $internship);

        $validated = $request->validated();

        $file = $validated['file'];
        $path = $file->store('mobile/reports', 'public');

        $report = Report::query()->create([
            'internship_id' => $internship->id,
            'student_id' => $request->user()->id,
            'report_type' => $validated['report_type'],
            'title' => $validated['title'],
            'file_path' => $path,
            'file_name' => $file->getClientOriginalName(),
            'file_extension' => $file->getClientOriginalExtension(),
            'file_size' => $file->getSize(),
            'status' => 'submitted',
            'submitted_at' => now(),
        ]);

        return response()->json([
            'message' => 'Report uploaded successfully.',
            'data' => ReportResource::make($report),
        ], 201);
    }

    public function show(Request $request, Report $report): JsonResponse
    {
        $this->authorize('view', $report);

        return response()->json([
            'data' => ReportResource::make($report),
        ]);
    }

    public function download(Request $request, Report $report): JsonResponse
    {
        $this->authorize('view', $report);

        return response()->json([
            'data' => [
                'file_path' => $report->file_path,
            ],
        ]);
    }

    public function destroy(Request $request, Report $report): JsonResponse
    {
        $this->authorize('delete', $report);

        $report->delete();

        return response()->json([
            'message' => 'Report deleted successfully.',
        ]);
    }
}
