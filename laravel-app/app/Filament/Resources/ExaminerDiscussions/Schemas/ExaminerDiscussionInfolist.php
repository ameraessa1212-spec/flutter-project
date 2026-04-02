<?php

namespace App\Filament\Resources\ExaminerDiscussions\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class ExaminerDiscussionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('internship.title')
                    ->label('التدريب'),
                TextEntry::make('student.name')
                    ->label('الطالب'),
                TextEntry::make('examiner.name')
                    ->label('الممتحن'),
                TextEntry::make('scheduled_at')
                    ->label('موعد المناقشة')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('location')
                    ->label('الموقع')
                    ->placeholder('-'),
                TextEntry::make('meeting_link')
                    ->label('رابط الاجتماع')
                    ->placeholder('-'),
                TextEntry::make('status')
                    ->label('الحالة'),
                IconEntry::make('is_urgent')
                    ->label('عاجل')
                    ->boolean(),
                TextEntry::make('notes')
                    ->label('ملاحظات')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime(),
            ]);
    }
}
