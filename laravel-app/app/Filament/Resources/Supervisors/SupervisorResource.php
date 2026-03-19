<?php

namespace App\Filament\Resources\Supervisors;

use App\Filament\Resources\Supervisors\Pages\CreateSupervisor;
use App\Filament\Resources\Supervisors\Pages\EditSupervisor;
use App\Filament\Resources\Supervisors\Pages\ListSupervisors;
use App\Filament\Resources\Supervisors\Pages\ViewSupervisor;
use App\Filament\Resources\Supervisors\Schemas\SupervisorForm;
use App\Filament\Resources\Supervisors\Schemas\SupervisorInfolist;
use App\Filament\Resources\Supervisors\Tables\SupervisorsTable;
use App\Models\Supervisor;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class SupervisorResource extends Resource
{
    protected static ?string $model = Supervisor::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedIdentification;

    protected static ?string $navigationLabel = 'المشرفون';

    protected static string|UnitEnum|null $navigationGroup = 'الدليل';

    protected static ?int $navigationSort = 3;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('users.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('users.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('users.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return SupervisorForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return SupervisorInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return SupervisorsTable::configure($table);
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
            'index' => ListSupervisors::route('/'),
            'create' => CreateSupervisor::route('/create'),
            'view' => ViewSupervisor::route('/{record}'),
            'edit' => EditSupervisor::route('/{record}/edit'),
        ];
    }
}
