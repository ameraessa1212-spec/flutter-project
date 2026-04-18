<?php

namespace App\Http\Resources\Mobile;

use App\Services\PublicMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'full_name_snapshot' => $this->full_name_snapshot,
            'phone_snapshot' => $this->phone_snapshot,
            'email_snapshot' => $this->email_snapshot,
            'university_snapshot' => $this->university_snapshot,
            'major_snapshot' => $this->major_snapshot,
            'level_snapshot' => $this->level_snapshot,
            'cv_file_url' => PublicMediaUrl::forPath($this->cv_file_path),
            'notes' => $this->notes,
            'submitted_at' => optional($this->submitted_at)?->toIso8601String(),
            'reviewed_at' => optional($this->reviewed_at)?->toIso8601String(),
            'review_notes' => $this->review_notes,
            'company' => new CompanyResource($this->whenLoaded('company')),
            'opportunity' => new InternshipOpportunityResource($this->whenLoaded('opportunity')),
            'internship' => new InternshipResource($this->whenLoaded('internship')),
        ];
    }
}
