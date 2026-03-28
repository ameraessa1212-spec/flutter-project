<?php

namespace App\Filament\Resources\DiscussionEvaluations\Pages;

use App\Filament\Resources\DiscussionEvaluations\DiscussionEvaluationResource;
use App\Models\ExaminerDiscussion;
use Filament\Resources\Pages\CreateRecord;

class CreateDiscussionEvaluation extends CreateRecord
{
    protected static string $resource = DiscussionEvaluationResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (auth()->user()?->hasRole('examiner')) {
            $data['examiner_id'] = auth()->id();
        }

        if (! empty($data['examiner_discussion_id'])) {
            $discussion = ExaminerDiscussion::find($data['examiner_discussion_id']);
            if ($discussion) {
                $data['internship_id'] = $discussion->internship_id;
                $data['student_id'] = $discussion->student_id;
                $data['examiner_id'] = $discussion->examiner_id;
            }
        }

        $data['submitted_at'] = $data['submitted_at'] ?? now();

        return $data;
    }
}
