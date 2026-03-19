<?php

namespace App\Filament\Resources\Applications\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class ApplicationInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('student.name')
                    ->label('الطالب'),
                TextEntry::make('opportunity.title')
                    ->label('فرصة التدريب'),
                TextEntry::make('company.name')
                    ->label('الشركة'),
                TextEntry::make('full_name_snapshot')
                    ->label('الاسم الكامل'),
                TextEntry::make('phone_snapshot')
                    ->label('رقم الهاتف')
                    ->placeholder('-'),
                TextEntry::make('email_snapshot')
                    ->label('البريد الإلكتروني')
                    ->placeholder('-'),
                TextEntry::make('university_snapshot')
                    ->label('الجامعة')
                    ->placeholder('-'),
                TextEntry::make('major_snapshot')
                    ->label('التخصص')
                    ->placeholder('-'),
                TextEntry::make('level_snapshot')
                    ->label('المستوى الدراسي')
                    ->placeholder('-'),
                TextEntry::make('cv_file_path')
                    ->label('السيرة الذاتية')
                    ->placeholder('-'),
                TextEntry::make('notes')
                    ->label('ملاحظات')
                    ->placeholder('-')
                    ->columnSpanFull(),
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
                TextEntry::make('reviewer.name')
                    ->label('راجعه')
                    ->placeholder('-'),
                TextEntry::make('review_notes')
                    ->label('ملاحظات المراجعة')
                    ->placeholder('-')
                    ->columnSpanFull(),
            ]);
    }
}

