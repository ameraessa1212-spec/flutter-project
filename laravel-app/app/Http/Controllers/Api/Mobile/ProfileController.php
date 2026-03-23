<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\UpdatePasswordRequest;
use App\Http\Requests\Api\Mobile\UpdateProfileRequest;
use App\Http\Requests\Api\Mobile\UploadAvatarRequest;
use App\Http\Requests\Api\Mobile\UploadCvRequest;
use App\Http\Resources\Mobile\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load(['studentProfile.specialization', 'settings']);

        return response()->json([
            'data' => [
                'user' => UserResource::make($user),
            ],
        ]);
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = $request->user();
        $user->fill($validated);

        if (! isset($validated['name']) && (isset($validated['first_name']) || isset($validated['last_name']))) {
            $user->name = trim(($user->first_name ?? '').' '.($user->last_name ?? ''));
        }

        $user->save();

        return response()->json([
            'message' => 'Profile updated successfully.',
            'data' => [
                'user' => UserResource::make($user->fresh(['studentProfile.specialization', 'settings'])),
            ],
        ]);
    }

    public function updatePassword(UpdatePasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = $request->user();

        if (! Hash::check($validated['current_password'], $user->password ?? '')) {
            return response()->json([
                'message' => 'Current password is incorrect.',
            ], 422);
        }

        $user->forceFill([
            'password' => Hash::make($validated['password']),
        ])->save();

        return response()->json([
            'message' => 'Password changed successfully.',
        ]);
    }

    public function uploadAvatar(UploadAvatarRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $path = $validated['avatar']->store('mobile/profile-avatars', 'public');

        $profile = $request->user()->studentProfile;
        if ($profile) {
            $profile->update(['profile_image_path' => $path]);
        }

        return response()->json([
            'message' => 'Avatar uploaded successfully.',
            'data' => [
                'path' => $path,
            ],
        ], 201);
    }

    public function uploadCv(UploadCvRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $path = $validated['cv']->store('mobile/student-cv', 'public');

        $profile = $request->user()->studentProfile;
        if ($profile) {
            $profile->update(['cv_file_path' => $path]);
        }

        return response()->json([
            'message' => 'CV uploaded successfully.',
            'data' => [
                'path' => $path,
            ],
        ], 201);
    }

    public function updateFcmToken(Request $request): JsonResponse
    {
        $request->validate([
            'fcm_token' => ['required', 'string'],
        ]);

        $request->user()->update([
            'fcm_token' => $request->fcm_token,
        ]);

        return response()->json([
            'message' => 'FCM token updated successfully.',
        ]);
    }
}
