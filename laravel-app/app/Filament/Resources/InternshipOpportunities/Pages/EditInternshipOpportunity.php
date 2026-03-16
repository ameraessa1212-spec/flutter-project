<?php

namespace App\Filament\Resources\InternshipOpportunities\Pages;

use App\Filament\Resources\InternshipOpportunities\InternshipOpportunityResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditInternshipOpportunity extends EditRecord
{
    protected static string $resource = InternshipOpportunityResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
