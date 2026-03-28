<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Models\Internship;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class InternshipController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $status = $request->query('status');
        
        $query = Internship::with(['student', 'opportunity'])
            ->where('company_id', Auth::user()->company->id);

        if ($status) {
            $query->where('status', $status);
        }

        return response()->json($query->latest()->get());
    }

    /**
     * Display the specified resource.
     */
    public function show(Internship $internship)
    {
        // Ensure the internship belongs to the company
        if ($internship->company_id !== Auth::user()->company->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $internship->load(['student', 'opportunity']);
        
        return response()->json($internship);
    }
}
