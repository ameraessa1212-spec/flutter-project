<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Supervisor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SupervisorController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Supervisor::with('company');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($companyId = $request->input('company_id')) {
            $query->where('company_id', $companyId);
        }

        $supervisors = $query->latest()->get()->map(function ($supervisor) {
            return [
                'id' => $supervisor->id,
                'name' => $supervisor->name,
                'email' => $supervisor->email,
                'phone' => $supervisor->phone,
                'department' => $supervisor->department,
                'is_active' => $supervisor->is_active,
                'company_name' => $supervisor->company?->name,
            ];
        });

        return response()->json(['data' => $supervisors]);
    }

    public function toggleStatus(Supervisor $supervisor): JsonResponse
    {
        $supervisor->update(['is_active' => !$supervisor->is_active]);

        return response()->json([
            'message' => $supervisor->is_active ? 'تم تفعيل المشرف.' : 'تم تعطيل المشرف.',
            'data' => ['is_active' => $supervisor->is_active],
        ]);
    }
}
