<?php

namespace App\Http\Requests\Api\Mobile;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'username' => ['required', 'string', 'max:100', 'unique:users,username'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
            'student_number' => ['required', 'string', 'max:50', 'unique:student_profiles,student_number', 'exists:eligible_students,student_number'],
            'specialization_id' => ['nullable', 'integer', 'exists:specializations,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'student_number.exists' => 'رقم القيد غير مطابق لشروط التدريب (لم يتم إكمال المواد أو يوجد دور ثاني).',
            'password.min' => 'كلمة المرور يجب ألا تقل عن 6 أحرف.',
        ];
    }
}
