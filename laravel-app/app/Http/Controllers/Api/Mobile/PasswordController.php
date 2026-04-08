<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\ForgotPasswordRequest;
use App\Http\Requests\Api\Mobile\ResetPasswordRequest;
use App\Http\Requests\Api\Mobile\VerifyResetOtpRequest;
use App\Mail\OtpMail;
use App\Models\PasswordResetOtp;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class PasswordController extends Controller
{
    public function forgot(ForgotPasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::query()
            ->where('email', $validated['identifier'])
            ->orWhere('phone', $validated['identifier'])
            ->first();

        if (! $user) {
            throw ValidationException::withMessages([
                'identifier' => ['لم يتم العثور على المستخدم.'],
            ]);
        }

        // Delete any previous OTPs for this identifier
        PasswordResetOtp::where('identifier', $validated['identifier'])->delete();

        // Generate a 6-digit OTP
        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        PasswordResetOtp::create([
            'identifier' => $validated['identifier'],
            'otp' => $otp,
            'expires_at' => now()->addMinutes(10),
        ]);

        // Send OTP via email
        if ($user->email) {
            Mail::to($user->email)->send(new OtpMail(
                otp: $otp,
                userName: $user->name,
            ));
        }

        return response()->json([
            'message' => 'تم إرسال رمز التحقق بنجاح.',
            'data' => [
                'identifier' => $validated['identifier'],
            ],
        ]);
    }

    public function verify(VerifyResetOtpRequest $request): JsonResponse
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

        $otpRecord->update(['verified_at' => now()]);

        return response()->json([
            'message' => 'تم التحقق من الرمز بنجاح.',
        ]);
    }

    public function reset(ResetPasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $otpRecord = PasswordResetOtp::where('identifier', $validated['identifier'])
            ->where('otp', $validated['otp'])
            ->whereNotNull('verified_at')
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
            'password' => Hash::make($validated['password']),
        ])->save();

        // Clean up used OTPs
        PasswordResetOtp::where('identifier', $validated['identifier'])->delete();

        return response()->json([
            'message' => 'تم إعادة تعيين كلمة المرور بنجاح.',
        ]);
    }
}
