<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class UserInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('supabase_user_id')
                    ->placeholder('-'),
                TextEntry::make('name')
                    ->placeholder('-'),
                TextEntry::make('email')
                    ->label('Email address')
                    ->placeholder('-'),
                TextEntry::make('email_verified_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('user_metadata')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('last_sign_in_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('first_name')
                    ->placeholder('-'),
                TextEntry::make('last_name')
                    ->placeholder('-'),
                TextEntry::make('username')
                    ->placeholder('-'),
                TextEntry::make('phone')
                    ->placeholder('-'),
                TextEntry::make('role'),
                TextEntry::make('status'),
                TextEntry::make('phone_verified_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('last_login_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
