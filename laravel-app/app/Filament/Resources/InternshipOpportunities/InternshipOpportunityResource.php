<?php

namespace App\Filament\Resources\InternshipOpportunities;

use App\Filament\Resources\InternshipOpportunities\Pages\CreateInternshipOpportunity;
use App\Filament\Resources\InternshipOpportunities\Pages\EditInternshipOpportunity;
use App\Filament\Resources\InternshipOpportunities\Pages\ListInternshipOpportunities;
use App\Filament\Resources\InternshipOpportunities\Pages\ViewInternshipOpportunity;
use App\Filament\Resources\InternshipOpportunities\Schemas\InternshipOpportunityForm;
use App\Filament\Resources\InternshipOpportunities\Schemas\InternshipOpportunityInfolist;
use App\Filament\Resources\InternshipOpportunities\Tables\InternshipOpportunitiesTable;
use App\Models\InternshipOpportunity;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class InternshipOpportunityResource extends Resource
{
    protected static ?string $model = InternshipOpportunity::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBriefcase;

    protected static ?string $navigationLabel = 'فرص التدريب';

    protected static string|UnitEnum|null $navigationGroup = 'الفرص';

    protected static ?int $navigationSort = 1;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('opportunities.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('opportunities.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('opportunities.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return InternshipOpportunityForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return InternshipOpportunityInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return InternshipOpportunitiesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListInternshipOpportunities::route('/'),
            'create' => CreateInternshipOpportunity::route('/create'),
            'view' => ViewInternshipOpportunity::route('/{record}'),
            'edit' => EditInternshipOpportunity::route('/{record}/edit'),
        ];
    }
}
