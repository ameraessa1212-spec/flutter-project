<?php

namespace App\Filament\Resources\InternshipOpportunities\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class InternshipOpportunityInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)->schema([
                    Section::make('معلومات الفرصة')
                        ->schema([
                            TextEntry::make('title')->label('العنوان'),
                            TextEntry::make('company.name')->label('الشركة'),
                            TextEntry::make('specialization.name')->label('التخصص')->placeholder('-'),
                            TextEntry::make('status')->label('الحالة')->badge(),
                            TextEntry::make('description')->label('الوصف')->columnSpanFull(),
                        ])->columns(2)->columnSpan(2),

                    Section::make('تفاصيل إضافية')
                        ->schema([
                            ImageEntry::make('image_path')->label('صورة الإعلان')->placeholder('-')->columnSpanFull(),
                            IconEntry::make('is_available')->label('متاحة للتقديم')->boolean(),
                        ])->columns(1)->columnSpan(1),
                        
                    Section::make('الزمان والمكان')
                        ->schema([
                            TextEntry::make('city')->label('المدينة')->placeholder('-'),
                            TextEntry::make('location_text')->label('العنوان كامل')->placeholder('-')->columnSpanFull(),
                            TextEntry::make('start_date')->label('تاريخ البداية')->date()->placeholder('-'),
                            TextEntry::make('end_date')->label('تاريخ النهاية')->date()->placeholder('-'),
                            TextEntry::make('duration_text')->label('مدة التدريب المكتوبة')->placeholder('-'),
                            TextEntry::make('duration_days')->label('عدد الأيام')->numeric()->placeholder('-'),
                        ])->columns(2)->columnSpan(2),
                        
                    Section::make('الحالة والمقاعد')
                        ->schema([
                            TextEntry::make('seats_count')->label('المقاعد الإجمالية')->numeric()->placeholder('0'),
                            TextEntry::make('available_seats')->label('المقاعد المتبقية')->numeric()->placeholder('0')->default(fn ($record) => $record?->available_seats ?? $record?->seats_count),
                            TextEntry::make('application_deadline')->label('آخر موعد للتقديم')->date()->placeholder('-'),
                            TextEntry::make('created_at')->label('تاريخ النشر')->dateTime()->placeholder('-'),
                        ])->columns(1)->columnSpan(1),
                ]),
            ]);
    }
}
