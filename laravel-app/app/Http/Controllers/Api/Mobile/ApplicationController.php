<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\StoreApplicationRequest;
use App\Http\Resources\Mobile\ApplicationResource;
use App\Models\Application;
use App\Models\InternshipOpportunity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ApplicationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $applications = Application::query()
            ->with(['company', 'opportunity'])
            ->where('student_id', $request->user()->id)
            ->latest()
            ->paginate((int) $request->integer('per_page', 15));

        return ApplicationResource::collection($applications)->response();
    }

    public function show(Request $request, Application $application): JsonResponse
    {
        $this->authorize('view', $application);

        $application->load(['company', 'opportunity', 'internship']);

        return response()->json([
            'data' => ApplicationResource::make($application),
        ]);
    }

    public function store(StoreApplicationRequest $request, InternshipOpportunity $opportunity): JsonResponse
    {
        $validated = $request->validated();
        $user = $request->user();
        $studentProfile = $user->studentProfile;

        $cvPath = null;
        if ($request->hasFile('cv')) {
            $cvPath = $request->file('cv')->store('mobile/applications/cv', 'public');
        }

        $application = Application::query()->create([
            'student_id' => $user->id,
            'opportunity_id' => $opportunity->id,
            'company_id' => $opportunity->company_id,
            'full_name_snapshot' => $validated['full_name_snapshot'] ?? $user->name ?? trim($user->first_name . ' ' . $user->last_name),
            'phone_snapshot' => $validated['phone_snapshot'] ?? $user->phone,
            'email_snapshot' => $validated['email_snapshot'] ?? $user->email,
            'university_snapshot' => $validated['university_snapshot'] ?? $studentProfile?->university_name,
            'major_snapshot' => $validated['major_snapshot'] ?? $studentProfile?->major,
            'level_snapshot' => $validated['level_snapshot'] ?? $studentProfile?->level,
            'cv_file_path' => $cvPath,
            'notes' => $validated['notes'] ?? null,
            'status' => 'pending',
            'submitted_at' => now(),
        ]);

        return response()->json([
            'message' => 'Application submitted successfully.',
            'data' => ApplicationResource::make($application->load(['company', 'opportunity'])),
        ], 201);
    }

    public function destroy(Request $request, Application $application): JsonResponse
    {
        $this->authorize('delete', $application);

        $application->update([
            'status' => 'withdrawn',
        ]);

        return response()->json([
            'message' => 'Application withdrawn successfully.',
        ]);
    }
}
