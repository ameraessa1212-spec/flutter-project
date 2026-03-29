<?php

namespace App\Http\Resources\Mobile;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class InternshipOpportunityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'city' => $this->city,
            'location_text' => $this->location_text,
            'duration_text' => $this->duration_text,
            'duration_days' => $this->duration_days,
            'seats_count' => $this->seats_count,
            'is_available' => (bool) $this->is_available,
            'status' => $this->status,
            'start_date' => optional($this->start_date)?->toDateString(),
            'end_date' => optional($this->end_date)?->toDateString(),
            'application_deadline' => optional($this->application_deadline)?->toDateString(),
            'image_path' => $this->image_path ? url(Storage::disk('public')->url($this->image_path)) : null,
            'company' => new CompanyResource($this->whenLoaded('company')),
            'specialization' => new SpecializationResource($this->whenLoaded('specialization')),
        ];
    }
}
