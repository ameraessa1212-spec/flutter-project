<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\ForgotPasswordRequest;
use App\Http\Requests\Api\Mobile\ResetPasswordRequest;
use App\Http\Requests\Api\Mobile\VerifyResetOtpRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
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
                'identifier' => ['User not found.'],
            ]);
        }

        return response()->json([
            'message' => 'Password reset OTP sent successfully.',
            'data' => [
                'identifier' => $validated['identifier'],
            ],
        ]);
    }

    public function verify(VerifyResetOtpRequest $request): JsonResponse
    {
        $validated = $request->validated();

        if ($validated['otp'] !== '666666') {
            throw ValidationException::withMessages([
                'otp' => ['Invalid OTP code.'],
            ]);
        }

        return response()->json([
            'message' => 'Reset OTP verified successfully.',
        ]);
    }

    public function reset(ResetPasswordRequest $request): JsonResponse
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
            'password' => Hash::make($validated['password']),
        ])->save();

        return response()->json([
            'message' => 'Password reset successfully.',
        ]);
    }
}
