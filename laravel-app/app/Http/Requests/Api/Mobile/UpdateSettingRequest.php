<?php

namespace App\Http\Requests\Api\Mobile;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSettingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'language' => ['sometimes', 'string', 'max:10'],
            'push_notifications_enabled' => ['sometimes', 'boolean'],
            'email_notifications_enabled' => ['sometimes', 'boolean'],
            'chat_notifications_enabled' => ['sometimes', 'boolean'],
            'theme' => ['sometimes', 'string', 'max:20'],
        ];
    }
}
