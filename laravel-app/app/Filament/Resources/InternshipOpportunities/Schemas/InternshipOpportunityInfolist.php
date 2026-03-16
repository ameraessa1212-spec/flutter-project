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
                    ->label('Company'),
                TextEntry::make('specialization.name')
                    ->label('Specialization')
                    ->placeholder('-'),
                TextEntry::make('title'),
                TextEntry::make('description')
                    ->columnSpanFull(),
                TextEntry::make('city')
                    ->placeholder('-'),
                TextEntry::make('location_text')
                    ->placeholder('-'),
                TextEntry::make('duration_text')
                    ->placeholder('-'),
                TextEntry::make('duration_days')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('seats_count')
                    ->numeric()
                    ->placeholder('-'),
                IconEntry::make('is_available')
                    ->boolean(),
                TextEntry::make('status'),
                TextEntry::make('start_date')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('end_date')
                    ->date()
                    ->placeholder('-'),
                TextEntry::make('application_deadline')
                    ->date()
                    ->placeholder('-'),
                ImageEntry::make('image_path')
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
