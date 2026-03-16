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
                    ->label('المستخدم'),
                TextEntry::make('title')
                    ->label('العنوان'),
                TextEntry::make('body')
                    ->label('المحتوى')
                    ->columnSpanFull(),
                TextEntry::make('type')
                    ->label('النوع'),
                TextEntry::make('reference_type')
                    ->label('نوع المرجع')
                    ->placeholder('-'),
                TextEntry::make('reference_id')
                    ->label('معرف المرجع')
                    ->numeric()
                    ->placeholder('-'),
                IconEntry::make('is_read')
                    ->label('مقروء')
                    ->boolean(),
                TextEntry::make('read_at')
                    ->label('تاريخ القراءة')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->label('تاريخ التحديث')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
