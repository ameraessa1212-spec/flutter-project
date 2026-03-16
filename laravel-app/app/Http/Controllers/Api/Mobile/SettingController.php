<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\UpdateSettingRequest;
use App\Http\Resources\Mobile\UserSettingResource;
use App\Models\UserSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $settings = UserSetting::query()->firstOrCreate(
            ['user_id' => $request->user()->id],
            [
                'language' => 'ar',
                'push_notifications_enabled' => true,
                'email_notifications_enabled' => true,
                'chat_notifications_enabled' => true,
                'theme' => 'light',
            ]
        );

        $this->authorize('view', $settings);

        return response()->json([
            'data' => UserSettingResource::make($settings),
        ]);
    }

    public function update(UpdateSettingRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $settings = UserSetting::query()->firstOrCreate(
            ['user_id' => $request->user()->id],
            [
                'language' => 'ar',
                'push_notifications_enabled' => true,
                'email_notifications_enabled' => true,
                'chat_notifications_enabled' => true,
                'theme' => 'light',
            ]
        );

        $this->authorize('update', $settings);

        $settings->update($validated);

        return response()->json([
            'message' => 'Settings updated successfully.',
            'data' => UserSettingResource::make($settings->fresh()),
        ]);
    }
}
