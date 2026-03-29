<?php

namespace App\Http\Resources\Admin;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminApplicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student' => [
                'id' => $this->student?->id,
                'name' => $this->student?->name ?? $this->full_name_snapshot,
                'username' => $this->student?->username,
                'email' => $this->student?->email ?? $this->email_snapshot,
                'phone' => $this->student?->phone ?? $this->phone_snapshot,
                'student_number' => $this->student?->studentProfile?->student_number,
                'specialization' => $this->student?->studentProfile?->specialization?->name ?? $this->major_snapshot,
            ],
            'company' => [
                'id' => $this->company?->id,
                'name' => $this->company?->name,
            ],
            'opportunity' => [
                'id' => $this->opportunity?->id,
                'title' => $this->opportunity?->title,
            ],
            'status' => $this->status,
            'notes' => $this->notes,
            'review_notes' => $this->review_notes,
            'submitted_at' => $this->submitted_at?->toISOString(),
            'reviewed_at' => $this->reviewed_at?->toISOString(),
        ];
    }
}
