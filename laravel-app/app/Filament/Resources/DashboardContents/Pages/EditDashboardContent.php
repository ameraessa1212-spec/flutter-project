<?php

namespace App\Filament\Resources\DashboardContents\Pages;

use App\Filament\Resources\DashboardContents\DashboardContentResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditDashboardContent extends EditRecord
{
    protected static string $resource = DashboardContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}