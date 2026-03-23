<?php

namespace App\Filament\Resources\DashboardContents\Pages;

use App\Filament\Resources\DashboardContents\DashboardContentResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewDashboardContent extends ViewRecord
{
    protected static string $resource = DashboardContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}