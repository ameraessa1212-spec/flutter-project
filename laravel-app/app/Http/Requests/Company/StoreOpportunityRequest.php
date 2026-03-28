<?php

namespace App\Http\Requests\Company;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreOpportunityRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'specialization_id' => ['required', 'exists:specializations,id'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'city' => ['nullable', 'string', 'max:100'],
            'location_text' => ['nullable', 'string', 'max:255'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'duration_text' => ['nullable', 'string', 'max:50'],
            'seats_count' => ['required', 'integer', 'min:1'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
            'application_deadline' => ['nullable', 'date'],
        ];
    }
}
