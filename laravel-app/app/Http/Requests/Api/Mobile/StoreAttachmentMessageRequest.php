<?php

namespace App\Http\Requests\Api\Mobile;

use Illuminate\Foundation\Http\FormRequest;

class StoreAttachmentMessageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'attachment' => ['required', 'file', 'max:15360'],
            'message_type' => ['nullable', 'in:image,file'],
            'body' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
