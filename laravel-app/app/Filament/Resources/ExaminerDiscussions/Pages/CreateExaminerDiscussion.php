<?php

namespace App\Filament\Resources\ExaminerDiscussions\Pages;

use App\Filament\Resources\ExaminerDiscussions\ExaminerDiscussionResource;
use Filament\Resources\Pages\CreateRecord;

class CreateExaminerDiscussion extends CreateRecord
{
    protected static string $resource = ExaminerDiscussionResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (auth()->user()?->hasRole('examiner')) {
            $data['examiner_id'] = auth()->id();
        }

        return $data;
    }
}
