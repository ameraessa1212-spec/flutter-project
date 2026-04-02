<?php

namespace App\Http\Controllers\Api\Company;

use App\Http\Controllers\Controller;
use App\Http\Requests\Company\LoginCompanyRequest;
use App\Http\Requests\Company\RegisterCompanyRequest;
use App\Models\Company;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class CompanyAuthController extends Controller
{
    public function register(RegisterCompanyRequest $request): JsonResponse
    {
        $validated = $request->validated();

        // 1. Create a User for the company admin
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'company',
            'status' => 'inactive',
        ]);

        // 2. Handle logo file upload
        $logoPath = null;
        if ($request->hasFile('logo')) {
            $logoPath = $request->file('logo')->store('company-logos', 'public');
        }

        // 3. Create the Company profile linked to the User
        $company = Company::create([
            'user_id' => $user->id,
            'name' => $validated['name'],
            'slug' => Str::slug($validated['name']) . '-' . uniqid(),
            'email' => $validated['email'],
            'city' => $validated['city'] ?? null,
            'address' => $validated['address'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'description' => $validated['description'] ?? null,
            'logo_path' => $logoPath,
            'website_url' => $validated['website_url'] ?? null,
            'map_url' => $validated['map_url'] ?? null,
            'is_active' => false,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Company registered successfully. Pending admin approval.',
            'data' => [
                'user' => $user,
                'company' => $company,
            ],
        ], 201);
    }

    public function login(LoginCompanyRequest $request): JsonResponse
    {
        $validator = $request->validated();

        $user = User::where('email', $validator['email'])->first();

        if (!$user || !Hash::check($validator['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials.',
            ], 401);
        }

        if ($user->role !== 'company') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized role.',
            ], 403);
        }

        $company = Company::where('user_id', $user->id)->first();

        if (!$company || $company->status === 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Your company account is pending approval by the administration.',
            ], 403);
        }

        if ($company->status === 'rejected') {
            return response()->json([
                'success' => false,
                'message' => 'Your company account has been rejected.',
            ], 403);
        }

        $token = $user->createToken('company_auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'token' => $token,
                'user' => $user,
                'company' => $company,
            ]
        ]);
    }
}

