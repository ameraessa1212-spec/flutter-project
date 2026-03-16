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
                    ->label('Application'),
                TextEntry::make('student.name')
                    ->label('Student'),
                TextEntry::make('company.name')
                    ->label('Company'),
                TextEntry::make('opportunity.title')
                    ->label('Opportunity')
                    ->placeholder('-'),
                TextEntry::make('supervisor.name')
                    ->label('Supervisor')
                    ->placeholder('-'),
                TextEntry::make('title'),
                TextEntry::make('status'),
                TextEntry::make('start_date')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('end_date')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('report_due_date')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('notes')
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
