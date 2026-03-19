<?php

namespace App\Filament\Resources\DiscussionSchedules\Pages;

use App\Filament\Resources\DiscussionSchedules\DiscussionScheduleResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditDiscussionSchedule extends EditRecord
{
    protected static string $resource = DiscussionScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
