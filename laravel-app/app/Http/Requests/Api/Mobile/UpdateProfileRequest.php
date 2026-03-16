<?php

namespace App\Http\Requests\Api\Mobile;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()?->id;

        return [
            'first_name' => ['sometimes', 'string', 'max:100'],
            'last_name' => ['sometimes', 'string', 'max:100'],
            'name' => ['sometimes', 'string', 'max:255'],
            'username' => ['sometimes', 'string', 'max:100', 'unique:users,username,'.$userId],
            'email' => ['sometimes', 'email', 'max:255', 'unique:users,email,'.$userId],
            'phone' => ['sometimes', 'string', 'max:20', 'unique:users,phone,'.$userId],
        ];
    }
}
