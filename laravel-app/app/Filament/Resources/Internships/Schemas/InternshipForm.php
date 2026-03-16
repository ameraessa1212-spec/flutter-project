<?php

namespace App\Filament\Resources\Internships\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class InternshipForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('application_id')
                    ->relationship('application', 'id')
                    ->required(),
                Select::make('student_id')
                    ->relationship('student', 'name')
                    ->required(),
                Select::make('company_id')
                    ->relationship('company', 'name')
                    ->required(),
                Select::make('opportunity_id')
                    ->relationship('opportunity', 'title'),
                Select::make('supervisor_id')
                    ->relationship('supervisor', 'name'),
                TextInput::make('title')
                    ->required(),
                TextInput::make('status')
                    ->required()
                    ->default('active'),
                DatePicker::make('start_date'),
                DatePicker::make('end_date'),
                DatePicker::make('report_due_date'),
                Textarea::make('notes')
                    ->columnSpanFull(),
            ]);
    }
}
