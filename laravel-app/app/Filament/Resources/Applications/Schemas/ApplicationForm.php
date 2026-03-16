<?php

namespace App\Filament\Resources\Applications\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ApplicationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('student_id')
                    ->relationship('student', 'name')
                    ->required(),
                Select::make('opportunity_id')
                    ->relationship('opportunity', 'title')
                    ->required(),
                Select::make('company_id')
                    ->relationship('company', 'name')
                    ->required(),
                TextInput::make('full_name_snapshot')
                    ->required(),
                TextInput::make('phone_snapshot')
                    ->tel(),
                TextInput::make('email_snapshot')
                    ->email(),
                TextInput::make('university_snapshot'),
                TextInput::make('major_snapshot'),
                TextInput::make('level_snapshot'),
                TextInput::make('cv_file_path'),
                Textarea::make('notes')
                    ->columnSpanFull(),
                TextInput::make('status')
                    ->required()
                    ->default('pending'),
                DateTimePicker::make('submitted_at'),
                DateTimePicker::make('reviewed_at'),
                TextInput::make('reviewed_by')
                    ->numeric(),
                Textarea::make('review_notes')
                    ->columnSpanFull(),
            ]);
    }
}
