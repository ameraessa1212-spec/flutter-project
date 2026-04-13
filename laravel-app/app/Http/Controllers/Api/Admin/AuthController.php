<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\AdminLoginRequest;
use App\Http\Resources\Admin\AdminUserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(AdminLoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::query()
            ->where('email', $validated['login'])
            ->orWhere('username', $validated['login'])
            ->first();

        if (! $user || ! Hash::check($validated['password'], $user->password ?? '')) {
            throw ValidationException::withMessages([
                'login' => ['بيانات الدخول غير صحيحة.'],
            ]);
        }

        if ($user->status !== 'active') {
            throw ValidationException::withMessages([
                'login' => ['الحساب غير مفعل.'],
            ]);
        }

        $allowedRoles = ['super_admin', 'operations', 'supervisor', 'examiner', 'content_manager', 'support'];

        if (! in_array($user->role, $allowedRoles)) {
            throw ValidationException::withMessages([
                'login' => ['ليس لديك صلاحية الوصول للوحة التحكم.'],
            ]);
        }

        // Validate role matches user type
        if (isset($validated['role'])) {
            if ($validated['role'] === 'examiner' && $user->role !== 'examiner') {
                throw ValidationException::withMessages([
                    'login' => ['هذا الحساب ليس حساب ممتحن.'],
                ]);
            }
            if ($validated['role'] === 'admin' && $user->role === 'examiner') {
                throw ValidationException::withMessages([
                    'login' => ['هذا الحساب خاص بالممتحن. يرجى اختيار "ممتحن" للدخول.'],
                ]);
            }
        }

        $token = $user->createToken('admin-dashboard')->plainTextToken;

        $user->forceFill(['last_login_at' => now()])->save();

        return response()->json([
            'message' => 'تم تسجيل الدخول بنجاح.',
            'data' => [
                'token' => $token,
                'token_type' => 'Bearer',
                'user' => AdminUserResource::make($user)->resolve(),
            ],
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'data' => [
                'user' => AdminUserResource::make($request->user()),
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج بنجاح.',
        ]);
    }
}
