<?php

namespace App\Http\Resources\Mobile;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'name' => $this->name,
            'username' => $this->username,
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'status' => $this->status,
            'email_verified_at' => optional($this->email_verified_at)?->toIso8601String(),
            'phone_verified_at' => optional($this->phone_verified_at)?->toIso8601String(),
            'last_login_at' => optional($this->last_login_at)?->toIso8601String(),
            'student_profile' => new StudentProfileResource($this->whenLoaded('studentProfile')),
            'settings' => new UserSettingResource($this->whenLoaded('settings')),
        ];
    }
}
