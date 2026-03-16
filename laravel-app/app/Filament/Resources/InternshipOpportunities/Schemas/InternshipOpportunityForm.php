<?php

namespace App\Filament\Resources\InternshipOpportunities\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class InternshipOpportunityForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('company_id')
                    ->relationship('company', 'name')
                    ->required(),
                Select::make('specialization_id')
                    ->relationship('specialization', 'name'),
                TextInput::make('title')
                    ->required(),
                Textarea::make('description')
                    ->required()
                    ->columnSpanFull(),
                TextInput::make('city'),
                TextInput::make('location_text'),
                TextInput::make('duration_text'),
                TextInput::make('duration_days')
                    ->numeric(),
                TextInput::make('seats_count')
                    ->numeric(),
                Toggle::make('is_available')
                    ->required(),
                TextInput::make('status')
                    ->required()
                    ->default('draft'),
                DatePicker::make('start_date'),
                DatePicker::make('end_date'),
                DatePicker::make('application_deadline'),
                FileUpload::make('image_path')
                    ->image(),
            ]);
    }
}
