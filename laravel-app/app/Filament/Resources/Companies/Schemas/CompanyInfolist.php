<?php

namespace App\Filament\Resources\Companies\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CompanyInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)->schema([
                    Section::make('معلومات الشركة')
                        ->schema([
                            Grid::make(2)->schema([
                                TextEntry::make('name')->label('اسم الشركة'),
                                TextEntry::make('slug')->label('المعرف المختصر'),
                                TextEntry::make('email')->label('البريد الإلكتروني')->placeholder('-')->icon('heroicon-m-envelope'),
                                TextEntry::make('phone')->label('رقم الهاتف')->placeholder('-')->icon('heroicon-m-phone'),
                                TextEntry::make('city')->label('المدينة')->placeholder('-'),
                                TextEntry::make('address')->label('العنوان')->placeholder('-'),
                            ]),
                            TextEntry::make('description')->label('الوصف')->placeholder('-')->columnSpanFull(),
                        ])->columnSpan(2),
                        
                    Section::make('تفاصيل إضافية')
                        ->schema([
                            ImageEntry::make('logo_path')->label('الشعار')->circular(),
                            IconEntry::make('is_active')->label('نشطة')->boolean(),
                            TextEntry::make('website_url')->label('الموقع الإلكتروني')->url(fn ($state) => $state, true)->placeholder('-'),
                            TextEntry::make('map_url')->label('رابط الخريطة')->url(fn ($state) => $state, true)->placeholder('-'),
                            TextEntry::make('created_at')->label('تاريخ الإنشاء')->dateTime()->placeholder('-'),
                        ])->columnSpan(1),
                ])
            ]);
    }
}
