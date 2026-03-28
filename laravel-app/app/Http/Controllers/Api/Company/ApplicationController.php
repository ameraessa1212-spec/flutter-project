<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Models\Application;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ApplicationController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $status = $request->query('status');
        
        $query = Application::with(['student', 'opportunity'])
            ->where('company_id', Auth::user()->company->id);

        if ($status) {
            $query->where('status', $status);
        }

        return response()->json($query->latest()->get());
    }

    /**
     * Display the specified resource.
     */
    public function show(Application $application)
    {
        // Ensure the application belongs to the company
        if ($application->company_id !== Auth::user()->company->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $application->load(['student', 'opportunity']);
        
        return response()->json($application);
    }

    /**
     * Update the application status.
     */
    public function updateStatus(Request $request, Application $application)
    {
        // Ensure the application belongs to the company
        if ($application->company_id !== Auth::user()->company->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'status' => 'required|in:accepted,rejected,reviewing',
            'review_notes' => 'nullable|string'
        ]);

        $application->status = $validated['status'];
        $application->reviewed_by = Auth::id();
        $application->reviewed_at = now();
        
        if (isset($validated['review_notes'])) {
            $application->review_notes = $validated['review_notes'];
        }

        $application->save();

        if ($application->status === 'accepted') {
            if (!\App\Models\Internship::where('application_id', $application->id)->exists()) {
                 \App\Models\Internship::create([
                     'application_id' => $application->id,
                     'student_id' => $application->student_id,
                     'company_id' => $application->company_id,
                     'opportunity_id' => $application->opportunity_id,
                     'title' => $application->opportunity->title ?? 'Internship',
                     'status' => 'active'
                 ]);
            }
        }

        return response()->json([
            'message' => 'Status updated successfully',
            'application' => $application
        ]);
    }
}
