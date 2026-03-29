<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompanyAccountController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Company::with('user');

        if ($search = $request->input('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        $companies = $query->latest()->paginate($request->input('per_page', 20));

        $data = $companies->map(function ($company) {
            return [
                'id' => $company->id,
                'name' => $company->name,
                'email' => $company->email,
                'created_at' => $company->created_at?->toDateString(),
                'is_active' => $company->is_active,
            ];
        });

        return response()->json([
            'data' => $data,
            'meta' => [
                'current_page' => $companies->currentPage(),
                'last_page' => $companies->lastPage(),
                'total' => $companies->total(),
            ],
        ]);
    }

    public function toggleStatus(Company $company): JsonResponse
    {
        $newStatus = ! $company->is_active;
        $company->update(['is_active' => $newStatus]);

        if ($company->user) {
            $company->user->update(['status' => $newStatus ? 'active' : 'inactive']);
        }

        return response()->json([
            'message' => $newStatus ? 'تم تفعيل الشركة.' : 'تم تعطيل الشركة.',
            'data' => ['is_active' => $newStatus],
        ]);
    }
}
