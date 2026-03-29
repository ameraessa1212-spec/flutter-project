<?php

namespace App\Http\Resources\Admin;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminReportResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student' => [
                'id' => $this->student?->id,
                'name' => $this->student?->name,
                'student_number' => $this->student?->studentProfile?->student_number,
            ],
            'internship' => [
                'id' => $this->internship?->id,
                'company_name' => $this->internship?->company?->name,
            ],
            'report_type' => $this->report_type,
            'title' => $this->title,
            'file_name' => $this->file_name,
            'status' => $this->status,
            'submitted_at' => $this->submitted_at?->toISOString(),
            'reviewed_at' => $this->reviewed_at?->toISOString(),
            'download_url' => $this->file_path ? url("storage/{$this->file_path}") : null,
        ];
    }
}
