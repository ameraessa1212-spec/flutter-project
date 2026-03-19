<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Application extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'opportunity_id',
        'company_id',
        'full_name_snapshot',
        'phone_snapshot',
        'email_snapshot',
        'university_snapshot',
        'major_snapshot',
        'level_snapshot',
        'cv_file_path',
        'notes',
        'status',
        'submitted_at',
        'reviewed_at',
        'reviewed_by',
        'review_notes',
    ];

    protected function casts(): array
    {
        return [
            'submitted_at' => 'datetime',
            'reviewed_at' => 'datetime',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function opportunity(): BelongsTo
    {
        return $this->belongsTo(InternshipOpportunity::class, 'opportunity_id');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function internship(): HasOne
    {
        return $this->hasOne(Internship::class);
    }
}
