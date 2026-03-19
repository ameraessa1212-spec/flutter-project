<?php

namespace App\Filament\Resources\InternshipOpportunities\Pages;

use App\Filament\Resources\InternshipOpportunities\InternshipOpportunityResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListInternshipOpportunities extends ListRecords
{
    protected static string $resource = InternshipOpportunityResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
