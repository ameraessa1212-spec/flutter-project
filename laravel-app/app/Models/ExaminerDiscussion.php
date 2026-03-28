<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ExaminerDiscussion extends Model
{
    use HasFactory;

    protected $fillable = [
        'internship_id',
        'student_id',
        'examiner_id',
        'scheduled_at',
        'location',
        'meeting_link',
        'status',
        'is_urgent',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_at' => 'datetime',
            'is_urgent' => 'boolean',
        ];
    }

    public function internship(): BelongsTo
    {
        return $this->belongsTo(Internship::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function examiner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'examiner_id');
    }

    public function evaluation(): HasOne
    {
        return $this->hasOne(DiscussionEvaluation::class);
    }
}
