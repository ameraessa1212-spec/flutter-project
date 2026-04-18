<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Services\PublicMediaUrl;
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

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        $companies = $query->latest()->paginate($request->input('per_page', 20));

        $data = $companies->map(function ($company) {
            return [
                'id' => $company->id,
                'name' => $company->name,
                'email' => $company->email,
                'phone' => $company->phone,
                'city' => $company->city,
                'description' => $company->description,
                'logo_url' => PublicMediaUrl::forPath($company->logo_path),
                'created_at' => $company->created_at?->toDateString(),
                'is_active' => $company->is_active,
                'status' => $company->status ?? 'pending',
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
        $newStatus = !$company->is_active;
        $company->update(['is_active' => $newStatus]);

        if ($company->user) {
            $company->user->update(['status' => $newStatus ? 'active' : 'inactive']);

            // When deactivating, revoke all existing tokens so any live
            // company session is logged out immediately.
            if (! $newStatus) {
                $company->user->tokens()->delete();
            }
        }

        return response()->json([
            'message' => $newStatus ? 'تم تفعيل الشركة.' : 'تم تعطيل الشركة.',
            'data' => ['is_active' => $newStatus],
        ]);
    }

    /**
     * Approve a pending company registration.
     */
    public function approve(Company $company): JsonResponse
    {
        if ($company->status === 'approved') {
            return response()->json([
                'message' => 'الشركة مقبولة بالفعل.',
            ], 422);
        }

        $company->update([
            'status' => 'approved',
            'is_active' => true,
        ]);

        // Also activate the linked user account
        if ($company->user) {
            $company->user->update(['status' => 'active']);
        }

        return response()->json([
            'message' => 'تم قبول الشركة بنجاح. يمكن للشركة الآن تسجيل الدخول.',
            'data' => [
                'id' => $company->id,
                'status' => 'approved',
                'is_active' => true,
            ],
        ]);
    }

    /**
     * Reject a pending company registration.
     */
    public function reject(Request $request, Company $company): JsonResponse
    {
        if ($company->status === 'rejected') {
            return response()->json([
                'message' => 'الشركة مرفوضة بالفعل.',
            ], 422);
        }

        $company->update([
            'status' => 'rejected',
            'is_active' => false,
        ]);

        // Also deactivate the linked user account and revoke any live tokens
        if ($company->user) {
            $company->user->update(['status' => 'inactive']);
            $company->user->tokens()->delete();
        }

        return response()->json([
            'message' => 'تم رفض الشركة.',
            'data' => [
                'id' => $company->id,
                'status' => 'rejected',
                'is_active' => false,
            ],
        ]);
    }

    /**
     * Soft-delete a company account and its linked user.
     */
    public function destroy(Company $company): JsonResponse
    {
        if ($company->user) {
            $company->user->tokens()->delete();
            $company->user->delete();
        }

        $company->delete();

        return response()->json([
            'message' => 'تم حذف حساب الشركة.',
        ]);
    }
}
