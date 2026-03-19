<?php

namespace App\Http\Resources\Mobile;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserSettingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'language' => $this->language,
            'push_notifications_enabled' => (bool) $this->push_notifications_enabled,
            'email_notifications_enabled' => (bool) $this->email_notifications_enabled,
            'chat_notifications_enabled' => (bool) $this->chat_notifications_enabled,
            'theme' => $this->theme,
        ];
    }
}
