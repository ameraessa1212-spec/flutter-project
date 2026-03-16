<?php

namespace App\Filament\Resources\UserNotifications\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class UserNotificationInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('User'),
                TextEntry::make('title'),
                TextEntry::make('body')
                    ->columnSpanFull(),
                TextEntry::make('type'),
                TextEntry::make('reference_type')
                    ->placeholder('-'),
                TextEntry::make('reference_id')
                    ->numeric()
                    ->placeholder('-'),
                IconEntry::make('is_read')
                    ->boolean(),
                TextEntry::make('read_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
