<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Models\InternshipOpportunity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OpportunityController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $status = $request->query('status');
        
        $query = InternshipOpportunity::where('company_id', Auth::user()->company->id);

        if ($status) {
            $query->where('status', $status);
        }

        return response()->json($query->latest()->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'requirements' => 'nullable|string',
            'benefits' => 'nullable|string',
            'location' => 'required|string|max:255',
            'is_remote' => 'boolean',
            'duration_months' => 'nullable|integer',
            'start_date' => 'nullable|date',
            'status' => 'required|in:draft,published,closed'
        ]);

        $validated['company_id'] = Auth::user()->company->id;
        $validated['created_by'] = Auth::id();

        $opportunity = InternshipOpportunity::create($validated);

        return response()->json([
            'message' => 'Opportunity created successfully',
            'opportunity' => $opportunity
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(InternshipOpportunity $opportunity)
    {
        // Ensure the opportunity belongs to the company
        if ($opportunity->company_id !== Auth::user()->company->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($opportunity);
    }
}
