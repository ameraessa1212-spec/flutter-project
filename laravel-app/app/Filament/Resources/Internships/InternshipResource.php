<?php

namespace App\Filament\Resources\Internships;

use App\Filament\Resources\Internships\Pages\CreateInternship;
use App\Filament\Resources\Internships\Pages\EditInternship;
use App\Filament\Resources\Internships\Pages\ListInternships;
use App\Filament\Resources\Internships\Pages\ViewInternship;
use App\Filament\Resources\Internships\Schemas\InternshipForm;
use App\Filament\Resources\Internships\Schemas\InternshipInfolist;
use App\Filament\Resources\Internships\Tables\InternshipsTable;
use App\Models\Internship;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class InternshipResource extends Resource
{
    protected static ?string $model = Internship::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static string|UnitEnum|null $navigationGroup = 'Internships';

    protected static ?int $navigationSort = 1;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('internships.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('internships.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('internships.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return InternshipForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return InternshipInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return InternshipsTable::configure($table);
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
            'index' => ListInternships::route('/'),
            'create' => CreateInternship::route('/create'),
            'view' => ViewInternship::route('/{record}'),
            'edit' => EditInternship::route('/{record}/edit'),
        ];
    }
}
