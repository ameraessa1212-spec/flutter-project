<?php

namespace App\Http\Resources\Mobile;

use App\Services\PublicMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StudentProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'university_name' => $this->university_name,
            'student_number' => $this->student_number,
            'study_level' => $this->study_level,
            'bio' => $this->bio,
            'profile_image_path' => PublicMediaUrl::forPath($this->profile_image_path),
            'cv_file_path' => PublicMediaUrl::forPath($this->cv_file_path),
            'expected_graduation_at' => optional($this->expected_graduation_at)?->toDateString(),
            'specialization' => new SpecializationResource($this->whenLoaded('specialization')),
        ];
    }
}
