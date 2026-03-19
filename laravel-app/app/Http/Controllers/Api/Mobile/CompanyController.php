<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\CompanyIndexRequest;
use App\Http\Resources\Mobile\CompanyResource;
use App\Models\Company;
use Illuminate\Http\JsonResponse;

class CompanyController extends Controller
{
    public function index(CompanyIndexRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $companies = Company::query()
            ->when($request->filled('search'), function ($query) use ($request) {
                $search = (string) $request->string('search');
                $query->where(function ($inner) use ($search) {
                    $inner->where('name', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%")
                        ->orWhere('city', 'like', "%{$search}%");
                });
            })
            ->where('is_active', true)
            ->orderBy('name')
            ->paginate((int) ($validated['per_page'] ?? 15));

        return CompanyResource::collection($companies)->response();
    }

    public function show(Company $company): JsonResponse
    {
        return response()->json([
            'data' => CompanyResource::make($company),
        ]);
    }
}
