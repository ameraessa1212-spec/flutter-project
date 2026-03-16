<?php

namespace App\Filament\Resources\DiscussionSchedules\Pages;

use App\Filament\Resources\DiscussionSchedules\DiscussionScheduleResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListDiscussionSchedules extends ListRecords
{
    protected static string $resource = DiscussionScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
