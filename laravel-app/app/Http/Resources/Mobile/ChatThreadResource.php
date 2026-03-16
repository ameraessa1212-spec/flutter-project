<?php

namespace App\Http\Resources\Mobile;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChatThreadResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'internship_id' => $this->internship_id,
            'student_id' => $this->student_id,
            'supervisor_id' => $this->supervisor_id,
            'last_message_at' => optional($this->last_message_at)?->toIso8601String(),
            'status' => $this->status,
            'internship' => new InternshipResource($this->whenLoaded('internship')),
            'supervisor' => new SupervisorResource($this->whenLoaded('supervisor')),
        ];
    }
}
