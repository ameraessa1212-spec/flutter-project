<?php

namespace App\Filament\Resources\InternshipOpportunities\Pages;

use App\Filament\Resources\InternshipOpportunities\InternshipOpportunityResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewInternshipOpportunity extends ViewRecord
{
    protected static string $resource = InternshipOpportunityResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
