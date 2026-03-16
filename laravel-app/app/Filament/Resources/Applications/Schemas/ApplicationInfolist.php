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
                    ->label('Student'),
                TextEntry::make('opportunity.title')
                    ->label('Opportunity'),
                TextEntry::make('company.name')
                    ->label('Company'),
                TextEntry::make('full_name_snapshot'),
                TextEntry::make('phone_snapshot')
                    ->placeholder('-'),
                TextEntry::make('email_snapshot')
                    ->placeholder('-'),
                TextEntry::make('university_snapshot')
                    ->placeholder('-'),
                TextEntry::make('major_snapshot')
                    ->placeholder('-'),
                TextEntry::make('level_snapshot')
                    ->placeholder('-'),
                TextEntry::make('cv_file_path')
                    ->placeholder('-'),
                TextEntry::make('notes')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('status'),
                TextEntry::make('submitted_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('reviewed_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('reviewed_by')
                    ->numeric()
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
