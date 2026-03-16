<?php

namespace App\Filament\Resources\Companies\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class CompanyInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('name')
                    ->label('اسم الشركة'),
                TextEntry::make('slug')
                    ->label('المعرف المختصر'),
                TextEntry::make('description')
                    ->label('الوصف')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('logo_path')
                    ->label('مسار الشعار')
                    ->placeholder('-'),
                TextEntry::make('website_url')
                    ->label('الموقع الإلكتروني')
                    ->placeholder('-'),
                TextEntry::make('map_url')
                    ->label('رابط الخريطة')
                    ->placeholder('-'),
                TextEntry::make('city')
                    ->label('المدينة')
                    ->placeholder('-'),
                TextEntry::make('address')
                    ->label('العنوان')
                    ->placeholder('-'),
                TextEntry::make('phone')
                    ->label('رقم الهاتف')
                    ->placeholder('-'),
                TextEntry::make('email')
                    ->label('البريد الإلكتروني')
                    ->placeholder('-'),
                IconEntry::make('is_active')
                    ->label('نشطة')
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
