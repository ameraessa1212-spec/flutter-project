<?php

namespace App\Filament\Resources\Internships\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class InternshipInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('application.id')
                    ->label('الطلب'),
                TextEntry::make('student.name')
                    ->label('الطالب'),
                TextEntry::make('company.name')
                    ->label('الشركة'),
                TextEntry::make('opportunity.title')
                    ->label('فرصة التدريب')
                    ->placeholder('-'),
                TextEntry::make('supervisor.name')
                    ->label('المشرف')
                    ->placeholder('-'),
                TextEntry::make('title')
                    ->label('العنوان'),
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
                TextEntry::make('report_due_date')
                    ->label('موعد التقرير')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('notes')
                    ->label('ملاحظات')
                    ->placeholder('-')
                    ->columnSpanFull(),
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
