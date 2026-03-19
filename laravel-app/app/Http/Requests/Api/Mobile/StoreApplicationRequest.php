<?php

namespace App\Http\Requests\Api\Mobile;

use Illuminate\Foundation\Http\FormRequest;

class StoreApplicationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'full_name_snapshot' => ['required', 'string', 'max:255'],
            'phone_snapshot' => ['nullable', 'string', 'max:20'],
            'email_snapshot' => ['nullable', 'email', 'max:255'],
            'university_snapshot' => ['nullable', 'string', 'max:255'],
            'major_snapshot' => ['nullable', 'string', 'max:255'],
            'level_snapshot' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'cv' => ['nullable', 'file', 'mimes:pdf,doc,docx', 'max:10240'],
        ];
    }
}
