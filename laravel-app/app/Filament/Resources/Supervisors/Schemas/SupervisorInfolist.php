<?php

namespace App\Filament\Resources\Supervisors\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class SupervisorInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user.name')
                    ->label('حساب المستخدم')
                    ->placeholder('-'),
                TextEntry::make('company.name')
                    ->label('الشركة')
                    ->placeholder('-'),
                TextEntry::make('name')
                    ->label('الاسم'),
                TextEntry::make('phone')
                    ->label('رقم الهاتف')
                    ->placeholder('-'),
                TextEntry::make('email')
                    ->label('البريد الإلكتروني')
                    ->placeholder('-'),
                TextEntry::make('type')
                    ->label('النوع'),
                TextEntry::make('department')
                    ->label('القسم')
                    ->placeholder('-'),
                IconEntry::make('is_active')
                    ->label('نشط')
                    ->boolean(),
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
