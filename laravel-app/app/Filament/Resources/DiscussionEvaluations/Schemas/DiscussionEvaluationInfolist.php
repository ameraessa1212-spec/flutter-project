<?php

namespace App\Filament\Resources\DiscussionEvaluations\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class DiscussionEvaluationInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('discussion.student.name')
                    ->label('الطالب'),
                TextEntry::make('discussion.internship.title')
                    ->label('التدريب'),
                TextEntry::make('total_score')
                    ->label('الدرجة النهائية')
                    ->placeholder('-'),
                TextEntry::make('decision')
                    ->label('القرار'),
                TextEntry::make('notes')
                    ->label('ملاحظات الممتحن')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('submitted_at')
                    ->label('تاريخ الإرسال')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime(),
            ]);
    }
}
