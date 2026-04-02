<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegisteredCompanyController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Company::where('status', 'approved')
            ->withCount('internships');

        if ($search = $request->input('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        if ($specialization = $request->input('specialization')) {
            $query->whereHas('opportunities.specialization', function ($q) use ($specialization) {
                $q->where('name', 'like', "%{$specialization}%");
            });
        }

        $companies = $query->latest()->get();

        $data = $companies->map(function ($company) {
            return [
                'id' => $company->id,
                'name' => $company->name,
                'city' => $company->city,
                'address' => $company->address,
                'email' => $company->email,
                'phone' => $company->phone,
                'internships_count' => $company->internships_count,
                'is_active' => $company->is_active,
            ];
        });

        return response()->json([
            'data' => $data,
        ]);
    }
}
