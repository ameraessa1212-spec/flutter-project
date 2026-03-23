<?php

namespace App\Filament\Resources\DashboardContents;

use App\Filament\Resources\DashboardContents\Pages\CreateDashboardContent;
use App\Filament\Resources\DashboardContents\Pages\EditDashboardContent;
use App\Filament\Resources\DashboardContents\Pages\ListDashboardContents;
use App\Filament\Resources\DashboardContents\Pages\ViewDashboardContent;
use App\Filament\Resources\DashboardContents\Schemas\DashboardContentForm;
use App\Filament\Resources\DashboardContents\Schemas\DashboardContentInfolist;
use App\Filament\Resources\DashboardContents\Tables\DashboardContentsTable;
use App\Models\DashboardContent;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class DashboardContentResource extends Resource
{
    protected static ?string $model = DashboardContent::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedPresentationChartBar;

    protected static ?string $navigationLabel = 'محتوى الرئيسية';

    protected static string|UnitEnum|null $navigationGroup = 'المحتوى';

    protected static ?int $navigationSort = 1;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('content.manage') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('content.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('content.manage') ?? false;
    }

    public static function canDelete($record): bool
    {
        return auth()->user()?->can('content.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return DashboardContentForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return DashboardContentInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return DashboardContentsTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListDashboardContents::route('/'),
            'create' => CreateDashboardContent::route('/create'),
            'view' => ViewDashboardContent::route('/{record}'),
            'edit' => EditDashboardContent::route('/{record}/edit'),
        ];
    }
}