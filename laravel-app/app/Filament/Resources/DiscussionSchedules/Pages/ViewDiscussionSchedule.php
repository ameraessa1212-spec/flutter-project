<?php

namespace App\Filament\Resources\DiscussionSchedules\Pages;

use App\Filament\Resources\DiscussionSchedules\DiscussionScheduleResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewDiscussionSchedule extends ViewRecord
{
    protected static string $resource = DiscussionScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
