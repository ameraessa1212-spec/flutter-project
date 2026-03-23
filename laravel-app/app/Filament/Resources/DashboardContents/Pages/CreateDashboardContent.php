<?php

namespace App\Filament\Resources\DashboardContents\Pages;

use App\Filament\Resources\DashboardContents\DashboardContentResource;
use Filament\Resources\Pages\CreateRecord;

class CreateDashboardContent extends CreateRecord
{
    protected static string $resource = DashboardContentResource::class;
}