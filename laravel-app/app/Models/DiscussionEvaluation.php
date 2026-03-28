<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DiscussionEvaluation extends Model
{
    use HasFactory;

    protected $fillable = [
        'examiner_discussion_id',
        'internship_id',
        'student_id',
        'examiner_id',
        'total_score',
        'decision',
        'rubric_scores',
        'notes',
        'visible_to_supervisor',
        'visible_to_company',
        'visible_to_student',
        'submitted_at',
    ];

    protected function casts(): array
    {
        return [
            'total_score' => 'decimal:2',
            'rubric_scores' => 'array',
            'visible_to_supervisor' => 'boolean',
            'visible_to_company' => 'boolean',
            'visible_to_student' => 'boolean',
            'submitted_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::saved(function (self $evaluation): void {
            if (! $evaluation->wasChanged('submitted_at')) {
                return;
            }

            if (! $evaluation->submitted_at) {
                return;
            }

            $evaluation->notifyStakeholders();
        });
    }

    public function discussion(): BelongsTo
    {
        return $this->belongsTo(ExaminerDiscussion::class, 'examiner_discussion_id');
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

    public function notifyStakeholders(): void
    {
        $internship = $this->internship;
        $supervisors = collect();

        if ($this->visible_to_supervisor && $internship?->supervisor?->user) {
            $supervisors->push($internship->supervisor->user);
        }

        if ($this->visible_to_company && $internship?->company) {
            $companySupervisors = $internship->company->supervisors
                ->map(fn (Supervisor $supervisor) => $supervisor->user)
                ->filter();
            $supervisors = $supervisors->merge($companySupervisors);
        }

        $supervisors->unique('id')->each(function ($user): void {
            UserNotification::create([
                'user_id' => $user->id,
                'title' => 'تقييم مناقشة جديد',
                'body' => 'تمت إضافة تقييم جديد لمناقشة الطالب.',
                'type' => 'evaluation',
                'reference_type' => self::class,
                'reference_id' => $this->id,
                'is_read' => false,
            ]);
        });
    }
}
