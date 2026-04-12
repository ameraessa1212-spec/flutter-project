<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\InternshipOpportunity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompanyOfferController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = InternshipOpportunity::with(['company', 'specialization']);

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($specId = $request->input('specialization_id')) {
            $query->where('specialization_id', $specId);
        }

        if ($search = $request->input('search')) {
            $query->whereHas('company', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%");
            });
        }

        $offers = $query->latest()->paginate($request->input('per_page', 20));

        $data = $offers->map(function ($offer) {
            return [
                'id' => $offer->id,
                'company' => [
                    'id' => $offer->company?->id,
                    'name' => $offer->company?->name,
                    'email' => $offer->company?->email,
                    'description' => $offer->company?->description,
                    'city' => $offer->company?->city,
                    'address' => $offer->company?->address,
                    'website_url' => $offer->company?->website_url,
                ],
                'title' => $offer->title,
                'specialization' => $offer->specialization?->name,
                'seats_count' => $offer->seats_count,
                'duration_text' => $offer->duration_text,
                'duration_days' => $offer->duration_days,
                'city' => $offer->city,
                'location_text' => $offer->location_text,
                'status' => $offer->status,
                'start_date' => $offer->start_date?->toDateString(),
                'end_date' => $offer->end_date?->toDateString(),
            ];
        });

        return response()->json([
            'data' => $data,
            'meta' => [
                'current_page' => $offers->currentPage(),
                'last_page' => $offers->lastPage(),
                'total' => $offers->total(),
            ],
        ]);
    }

    public function approve(InternshipOpportunity $opportunity): JsonResponse
    {
        $opportunity->update(['status' => 'approved', 'is_available' => true]);

        if ($opportunity->company) {
            $opportunity->company->update(['status' => 'approved', 'is_active' => true]);
            if ($opportunity->company->user) {
                $opportunity->company->user->update(['status' => 'active']);
            }
        }

        return response()->json([
            'message' => 'تم قبول العرض بنجاح.',
        ]);
    }

    public function reject(InternshipOpportunity $opportunity): JsonResponse
    {
        $opportunity->update(['status' => 'rejected', 'is_available' => false]);

        return response()->json([
            'message' => 'تم رفض العرض.',
        ]);
    }
}
