<?php

namespace App\Filament\Resources\DiscussionEvaluations\Pages;

use App\Filament\Resources\DiscussionEvaluations\DiscussionEvaluationResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListDiscussionEvaluations extends ListRecords
{
    protected static string $resource = DiscussionEvaluationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
