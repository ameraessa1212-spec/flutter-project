<?php

namespace App\Filament\Resources\DashboardContents\Pages;

use App\Filament\Resources\DashboardContents\DashboardContentResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListDashboardContents extends ListRecords
{
    protected static string $resource = DashboardContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}