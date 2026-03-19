<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Resources\Mobile\SpecializationResource;
use App\Models\Specialization;
use Illuminate\Http\JsonResponse;

class SpecializationController extends Controller
{
    public function index(): JsonResponse
    {
        $specializations = Specialization::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get();

        return response()->json([
            'data' => SpecializationResource::collection($specializations),
        ]);
    }
}
