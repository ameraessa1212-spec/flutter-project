<?php

namespace App\Filament\Resources\DiscussionEvaluations\Pages;

use App\Filament\Resources\DiscussionEvaluations\DiscussionEvaluationResource;
use App\Models\ExaminerDiscussion;
use Filament\Resources\Pages\EditRecord;

class EditDiscussionEvaluation extends EditRecord
{
    protected static string $resource = DiscussionEvaluationResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
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

        if (empty($data['submitted_at'])) {
            $data['submitted_at'] = now();
        }

        return $data;
    }
}
