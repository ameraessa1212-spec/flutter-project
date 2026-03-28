<?php

namespace App\Filament\Resources\ExaminerDiscussions\Pages;

use App\Filament\Resources\ExaminerDiscussions\ExaminerDiscussionResource;
use Filament\Resources\Pages\EditRecord;

class EditExaminerDiscussion extends EditRecord
{
    protected static string $resource = ExaminerDiscussionResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        if (auth()->user()?->hasRole('examiner')) {
            $data['examiner_id'] = auth()->id();
        }

        return $data;
    }
}
