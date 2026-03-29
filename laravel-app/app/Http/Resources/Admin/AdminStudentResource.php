<?php

namespace App\Http\Resources\Admin;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminStudentResource extends JsonResource
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
            'status' => $this->status,
            'student_number' => $this->studentProfile?->student_number,
            'specialization' => $this->studentProfile?->specialization?->name,
            'specialization_id' => $this->studentProfile?->specialization_id,
            'university_name' => $this->studentProfile?->university_name,
            'study_level' => $this->studentProfile?->study_level,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
