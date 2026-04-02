<?php

namespace App\Http\Resources\Mobile;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InternshipResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'status' => $this->status,
            'start_date' => optional($this->start_date)?->toDateString(),
            'end_date' => optional($this->end_date)?->toDateString(),
            'report_due_date' => optional($this->report_due_date)?->toDateString(),
            'notes' => $this->notes,
            'company' => $this->when(
                $this->relationLoaded('company') && $this->company !== null,
                fn () => CompanyResource::make($this->company),
            ),
            'opportunity' => $this->when(
                $this->relationLoaded('opportunity') && $this->opportunity !== null,
                fn () => InternshipOpportunityResource::make($this->opportunity),
            ),
            'supervisor' => $this->when(
                $this->relationLoaded('supervisor') && $this->supervisor !== null,
                fn () => SupervisorResource::make($this->supervisor),
            ),
        ];
    }
}
