<?php

namespace App\Filament\Resources\Reports\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class ReportInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('internship.title')
                    ->label('التدريب'),
                TextEntry::make('student.name')
                    ->label('الطالب'),
                TextEntry::make('report_type')
                    ->label('نوع التقرير'),
                TextEntry::make('title')
                    ->label('العنوان'),
                TextEntry::make('file_path')
                    ->label('مسار الملف'),
                TextEntry::make('file_name')
                    ->label('اسم الملف'),
                TextEntry::make('file_extension')
                    ->label('امتداد الملف')
                    ->placeholder('-'),
                TextEntry::make('file_size')
                    ->label('حجم الملف')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('status')
                    ->label('الحالة'),
                TextEntry::make('submitted_at')
                    ->label('تاريخ التقديم')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('reviewed_at')
                    ->label('تاريخ المراجعة')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('review_notes')
                    ->label('ملاحظات المراجعة')
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
