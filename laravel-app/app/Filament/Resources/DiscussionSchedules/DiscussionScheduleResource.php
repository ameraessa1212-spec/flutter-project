<?php

namespace App\Filament\Resources\DiscussionSchedules;

use App\Filament\Resources\DiscussionSchedules\Pages\CreateDiscussionSchedule;
use App\Filament\Resources\DiscussionSchedules\Pages\EditDiscussionSchedule;
use App\Filament\Resources\DiscussionSchedules\Pages\ListDiscussionSchedules;
use App\Filament\Resources\DiscussionSchedules\Pages\ViewDiscussionSchedule;
use App\Filament\Resources\DiscussionSchedules\Schemas\DiscussionScheduleForm;
use App\Filament\Resources\DiscussionSchedules\Schemas\DiscussionScheduleInfolist;
use App\Filament\Resources\DiscussionSchedules\Tables\DiscussionSchedulesTable;
use App\Models\DiscussionSchedule;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class DiscussionScheduleResource extends Resource
{
    protected static ?string $model = DiscussionSchedule::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCalendarDays;

    protected static ?string $navigationLabel = 'جداول المناقشة';

    protected static string|UnitEnum|null $navigationGroup = 'الأكاديمي';

    protected static ?int $navigationSort = 1;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('schedules.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('schedules.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('schedules.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return DiscussionScheduleForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return DiscussionScheduleInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return DiscussionSchedulesTable::configure($table);
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
            'index' => ListDiscussionSchedules::route('/'),
            'create' => CreateDiscussionSchedule::route('/create'),
            'view' => ViewDiscussionSchedule::route('/{record}'),
            'edit' => EditDiscussionSchedule::route('/{record}/edit'),
        ];
    }
}
