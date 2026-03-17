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
                TextEntry::make('name')
                    ->label('الاسم الكامل')
                    ->placeholder('-'),
                TextEntry::make('email')
                    ->label('البريد الإلكتروني')
                    ->placeholder('-'),
                TextEntry::make('email_verified_at')
                    ->label('تاريخ تحقق البريد')
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
                TextEntry::make('first_name')
                    ->label('الاسم الأول')
                    ->placeholder('-'),
                TextEntry::make('last_name')
                    ->label('اسم العائلة')
                    ->placeholder('-'),
                TextEntry::make('username')
                    ->label('اسم المستخدم')
                    ->placeholder('-'),
                TextEntry::make('phone')
                    ->label('رقم الهاتف')
                    ->placeholder('-'),
                TextEntry::make('role')
                    ->label('الدور'),
                TextEntry::make('status')
                    ->label('الحالة'),
                TextEntry::make('phone_verified_at')
                    ->label('تاريخ تحقق الهاتف')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('last_login_at')
                    ->label('آخر تسجيل دخول')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
