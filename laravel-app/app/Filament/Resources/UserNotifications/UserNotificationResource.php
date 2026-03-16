<?php

namespace App\Filament\Resources\UserNotifications;

use App\Filament\Resources\UserNotifications\Pages\CreateUserNotification;
use App\Filament\Resources\UserNotifications\Pages\EditUserNotification;
use App\Filament\Resources\UserNotifications\Pages\ListUserNotifications;
use App\Filament\Resources\UserNotifications\Pages\ViewUserNotification;
use App\Filament\Resources\UserNotifications\Schemas\UserNotificationForm;
use App\Filament\Resources\UserNotifications\Schemas\UserNotificationInfolist;
use App\Filament\Resources\UserNotifications\Tables\UserNotificationsTable;
use App\Models\UserNotification;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class UserNotificationResource extends Resource
{
    protected static ?string $model = UserNotification::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static string|UnitEnum|null $navigationGroup = 'Communication';

    protected static ?int $navigationSort = 1;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('notifications.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('notifications.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('notifications.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return UserNotificationForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return UserNotificationInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return UserNotificationsTable::configure($table);
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
            'index' => ListUserNotifications::route('/'),
            'create' => CreateUserNotification::route('/create'),
            'view' => ViewUserNotification::route('/{record}'),
            'edit' => EditUserNotification::route('/{record}/edit'),
        ];
    }
}
