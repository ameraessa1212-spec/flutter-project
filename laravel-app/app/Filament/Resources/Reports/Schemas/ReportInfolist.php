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
                    ->label('Internship'),
                TextEntry::make('student.name')
                    ->label('Student'),
                TextEntry::make('report_type'),
                TextEntry::make('title'),
                TextEntry::make('file_path'),
                TextEntry::make('file_name'),
                TextEntry::make('file_extension')
                    ->placeholder('-'),
                TextEntry::make('file_size')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('status'),
                TextEntry::make('submitted_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('reviewed_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('review_notes')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
