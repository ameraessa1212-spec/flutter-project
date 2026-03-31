<?php

namespace App\Http\Resources\Mobile;

use App\Services\PublicMediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CompanyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'logo_path' => PublicMediaUrl::forPath($this->logo_path),
            'active_opportunities_count' => $this->active_opportunities_count ?? 0,
            'website_url' => $this->website_url,
            'map_url' => $this->map_url,
            'city' => $this->city,
            'address' => $this->address,
            'phone' => $this->phone,
            'email' => $this->email,
            'is_active' => (bool) $this->is_active,
        ];
    }
}
