<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\LoginRequest;
use App\Http\Requests\Api\Mobile\RegisterRequest;
use App\Http\Requests\Api\Mobile\VerifyOtpRequest;
use App\Http\Resources\Mobile\UserResource;
use App\Mail\OtpMail;
use App\Models\PasswordResetOtp;
use App\Models\StudentProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
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

        // Generate and send OTP for account verification
        $this->sendOtp($user->email, $user->name);

        return response()->json([
            'message' => 'تم التسجيل بنجاح. يرجى التحقق من بريدك الإلكتروني لتفعيل الحساب.',
            'data' => [
                'user_id' => $user->id,
                'status' => $user->status,
            ],
        ], 201);
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $otpRecord = PasswordResetOtp::where('identifier', $validated['identifier'])
            ->where('otp', $validated['otp'])
            ->whereNull('verified_at')
            ->latest()
            ->first();

        if (! $otpRecord || $otpRecord->isExpired()) {
            throw ValidationException::withMessages([
                'otp' => ['رمز التحقق غير صحيح أو منتهي الصلاحية.'],
            ]);
        }

        $user = User::query()
            ->where('email', $validated['identifier'])
            ->orWhere('phone', $validated['identifier'])
            ->first();

        if (! $user) {
            throw ValidationException::withMessages([
                'identifier' => ['لم يتم العثور على المستخدم.'],
            ]);
        }

        $user->forceFill([
            'status' => 'active',
            'phone_verified_at' => now(),
            'email_verified_at' => $user->email_verified_at ?? now(),
        ])->save();

        // Clean up OTPs
        PasswordResetOtp::where('identifier', $validated['identifier'])->delete();

        return response()->json([
            'message' => 'تم التحقق بنجاح.',
            'data' => [
                'user_id' => $user->id,
                'status' => $user->status,
            ],
        ]);
    }

    public function resendOtp(Request $request): JsonResponse
    {
        $request->validate([
            'identifier' => ['required', 'string', 'max:255'],
        ]);

        $user = User::query()
            ->where('email', $request->input('identifier'))
            ->orWhere('phone', $request->input('identifier'))
            ->first();

        if (! $user) {
            throw ValidationException::withMessages([
                'identifier' => ['لم يتم العثور على المستخدم.'],
            ]);
        }

        $this->sendOtp($user->email, $user->name);

        return response()->json([
            'message' => 'تم إعادة إرسال رمز التحقق بنجاح.',
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
                'login' => ['بيانات الدخول غير صحيحة.'],
            ]);
        }

        if ($user->status !== 'active') {
            throw ValidationException::withMessages([
                'login' => ['الحساب غير مفعل بعد.'],
            ]);
        }

        $token = $user->createToken($validated['device_name'] ?? 'mobile-app')->plainTextToken;

        $user->forceFill([
            'last_login_at' => now(),
        ])->save();

        return response()->json([
            'message' => 'تم تسجيل الدخول بنجاح.',
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
            'message' => 'تم تسجيل الخروج بنجاح.',
        ]);
    }

    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()?->tokens()?->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج من جميع الأجهزة بنجاح.',
        ]);
    }

    private function sendOtp(string $identifier, string $userName): void
    {
        PasswordResetOtp::where('identifier', $identifier)->delete();

        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        PasswordResetOtp::create([
            'identifier' => $identifier,
            'otp' => $otp,
            'expires_at' => now()->addMinutes(10),
        ]);

        Mail::to($identifier)->send(new OtpMail(
            otp: $otp,
            userName: $userName,
        ));
    }
}
