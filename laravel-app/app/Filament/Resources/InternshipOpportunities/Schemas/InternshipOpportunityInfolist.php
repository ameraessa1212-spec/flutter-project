<?php

namespace App\Filament\Resources\InternshipOpportunities\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class InternshipOpportunityInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('company.name')
                    ->label('الشركة'),
                TextEntry::make('specialization.name')
                    ->label('التخصص')
                    ->placeholder('-'),
                TextEntry::make('title')
                    ->label('العنوان'),
                TextEntry::make('description')
                    ->label('الوصف')
                    ->columnSpanFull(),
                TextEntry::make('city')
                    ->label('المدينة')
                    ->placeholder('-'),
                TextEntry::make('location_text')
                    ->label('الموقع')
                    ->placeholder('-'),
                TextEntry::make('duration_text')
                    ->label('مدة التدريب')
                    ->placeholder('-'),
                TextEntry::make('duration_days')
                    ->label('عدد الأيام')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('seats_count')
                    ->label('عدد المقاعد')
                    ->numeric()
                    ->placeholder('-'),
                IconEntry::make('is_available')
                    ->label('متاحة')
                    ->boolean(),
                TextEntry::make('status')
                    ->label('الحالة'),
                TextEntry::make('start_date')
                    ->label('تاريخ البداية')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('end_date')
                    ->label('تاريخ النهاية')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('application_deadline')
                    ->label('آخر موعد للتقديم')
                    ->date()
                    ->placeholder('-'),
                ImageEntry::make('image_path')
                    ->label('الصورة')
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
