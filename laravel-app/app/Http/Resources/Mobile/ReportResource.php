<?php

namespace App\Http\Resources\Mobile;

use App\Services\PublicMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'report_type' => $this->report_type,
            'title' => $this->title,
            'file_url' => PublicMediaUrl::forPath($this->file_path),
            'file_name' => $this->file_name,
            'file_extension' => $this->file_extension,
            'file_size' => $this->file_size,
            'status' => $this->status,
            'submitted_at' => optional($this->submitted_at)?->toIso8601String(),
            'reviewed_at' => optional($this->reviewed_at)?->toIso8601String(),
            'review_notes' => $this->review_notes,
        ];
    }
}
