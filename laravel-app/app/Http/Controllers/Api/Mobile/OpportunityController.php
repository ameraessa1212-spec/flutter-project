<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\OpportunityIndexRequest;
use App\Http\Resources\Mobile\InternshipOpportunityResource;
use App\Models\InternshipOpportunity;
use Illuminate\Http\JsonResponse;

class OpportunityController extends Controller
{
    public function index(OpportunityIndexRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $opportunities = InternshipOpportunity::query()
            ->with(['company', 'specialization'])
            ->when($request->filled('specialization_id'), fn ($query) => $query->where('specialization_id', $request->integer('specialization_id')))
            ->when($request->filled('city'), fn ($query) => $query->where('city', 'like', '%'.$request->string('city').'%'))
            ->when($request->filled('is_available'), fn ($query) => $query->where('is_available', $request->boolean('is_available')))
            ->when($request->filled('search'), function ($query) use ($request) {
                $search = (string) $request->string('search');
                $query->where(function ($inner) use ($search) {
                    $inner->where('title', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%")
                        ->orWhereHas('company', function ($q) use ($search) {
                            $q->where('name', 'like', "%{$search}%");
                        });
                });
            })
            ->whereIn('status', ['published', 'closed'])
            ->latest()
            ->paginate((int) ($validated['per_page'] ?? 15));

        return InternshipOpportunityResource::collection($opportunities)->response();
    }

    public function show(InternshipOpportunity $opportunity): JsonResponse
    {
        $opportunity->load(['company', 'specialization']);

        return response()->json([
            'data' => InternshipOpportunityResource::make($opportunity),
        ]);
    }
}
