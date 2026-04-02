<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\Admin\AdminReportResource;
use App\Models\Report;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Report::with(['student', 'internship.company']);

        if ($search = $request->input('search')) {
            $query->whereHas('student', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%");
            });
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        $reports = $query->latest('submitted_at')->paginate($request->input('per_page', 20));

        return response()->json([
            'data' => AdminReportResource::collection($reports),
            'meta' => [
                'current_page' => $reports->currentPage(),
                'last_page' => $reports->lastPage(),
                'total' => $reports->total(),
            ],
        ]);
    }

    public function show(Report $report): JsonResponse
    {
        $report->load(['student', 'internship.company']);

        return response()->json([
            'data' => AdminReportResource::make($report),
        ]);
    }

    public function notify(Report $report): JsonResponse
    {
        UserNotification::create([
            'user_id' => $report->student_id,
            'title' => 'تم استلام التقرير',
            'body' => "تم استلام تقريرك \"{$report->title}\" بنجاح.",
            'type' => 'report',
            'reference_type' => Report::class,
            'reference_id' => $report->id,
        ]);

        return response()->json([
            'message' => 'تم إبلاغ الطالب بنجاح.',
        ]);
    }
}
