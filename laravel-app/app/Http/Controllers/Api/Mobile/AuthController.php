<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\LoginRequest;
use App\Http\Requests\Api\Mobile\RegisterRequest;
use App\Http\Requests\Api\Mobile\VerifyOtpRequest;
use App\Http\Resources\Mobile\UserResource;
use App\Models\StudentProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'],
            'name' => trim($validated['first_name'].' '.$validated['last_name']),
            'username' => $validated['username'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'password' => $validated['password'],
            'role' => 'student',
            'status' => 'pending',
        ]);

        $profileImagePath = null;
        if ($request->hasFile('profile_image')) {
            $profileImagePath = $request->file('profile_image')->store('mobile/profile-avatars', 'public');
        }

        StudentProfile::create([
            'user_id' => $user->id,
            'student_number' => $validated['student_number'] ?? null,
            'specialization_id' => $validated['specialization_id'] ?? null,
            'profile_image_path' => $profileImagePath,
        ]);

        return response()->json([
            'message' => 'Registration completed. Please verify OTP to activate account.',
            'data' => [
                'user_id' => $user->id,
                'status' => $user->status,
            ],
        ], 201);
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $validated = $request->validated();

        if ($validated['otp'] !== '666666') {
            throw ValidationException::withMessages([
                'otp' => ['Invalid OTP code.'],
            ]);
        }

        $user = User::query()
            ->where('email', $validated['identifier'])
            ->orWhere('phone', $validated['identifier'])
            ->first();

        if (! $user) {
            throw ValidationException::withMessages([
                'identifier' => ['User not found.'],
            ]);
        }

        $user->forceFill([
            'status' => 'active',
            'phone_verified_at' => now(),
            'email_verified_at' => $user->email_verified_at ?? now(),
        ])->save();

        return response()->json([
            'message' => 'OTP verified successfully.',
            'data' => [
                'user_id' => $user->id,
                'status' => $user->status,
            ],
        ]);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::query()
            ->where('email', $validated['login'])
            ->orWhere('username', $validated['login'])
            ->orWhere('phone', $validated['login'])
            ->first();

        if (! $user || ! Hash::check($validated['password'], $user->password ?? '')) {
            throw ValidationException::withMessages([
                'login' => ['Invalid credentials provided.'],
            ]);
        }

        if ($user->status !== 'active') {
            throw ValidationException::withMessages([
                'login' => ['Account is not active yet.'],
            ]);
        }

        $token = $user->createToken($validated['device_name'] ?? 'mobile-app')->plainTextToken;

        $user->forceFill([
            'last_login_at' => now(),
        ])->save();

        return response()->json([
            'message' => 'Login successful.',
            'data' => [
                'token' => $token,
                'token_type' => 'Bearer',
                'user' => UserResource::make($user)->resolve(),
            ],
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('studentProfile');

        return response()->json([
            'data' => [
                'user' => UserResource::make($user),
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'Logged out from current device successfully.',
        ]);
    }

    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()?->tokens()?->delete();

        return response()->json([
            'message' => 'Logged out from all devices successfully.',
        ]);
    }
}
