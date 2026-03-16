<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InternshipOpportunity extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_id',
        'specialization_id',
        'title',
        'description',
        'city',
        'location_text',
        'duration_text',
        'duration_days',
        'seats_count',
        'is_available',
        'status',
        'start_date',
        'end_date',
        'application_deadline',
        'image_path',
    ];

    protected function casts(): array
    {
        return [
            'duration_days' => 'integer',
            'seats_count' => 'integer',
            'is_available' => 'boolean',
            'start_date' => 'date',
            'end_date' => 'date',
            'application_deadline' => 'date',
        ];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function specialization(): BelongsTo
    {
        return $this->belongsTo(Specialization::class);
    }

    public function applications(): HasMany
    {
        return $this->hasMany(Application::class, 'opportunity_id');
    }

    public function internships(): HasMany
    {
        return $this->hasMany(Internship::class, 'opportunity_id');
    }
}
