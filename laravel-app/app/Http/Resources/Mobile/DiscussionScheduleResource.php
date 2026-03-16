<?php

namespace App\Http\Resources\Mobile;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DiscussionScheduleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'academic_term' => $this->academic_term,
            'schedule_file_path' => $this->schedule_file_path,
            'schedule_image_path' => $this->schedule_image_path,
            'published_at' => optional($this->published_at)?->toIso8601String(),
            'is_active' => (bool) $this->is_active,
            'specialization' => new SpecializationResource($this->whenLoaded('specialization')),
        ];
    }
}
