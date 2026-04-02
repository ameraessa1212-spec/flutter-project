<?php

namespace App\Filament\Resources\ExaminerDiscussions\Pages;

use App\Filament\Resources\ExaminerDiscussions\ExaminerDiscussionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListExaminerDiscussions extends ListRecords
{
    protected static string $resource = ExaminerDiscussionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
