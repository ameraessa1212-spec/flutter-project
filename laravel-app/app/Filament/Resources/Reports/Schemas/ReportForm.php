<?php

namespace App\Filament\Resources\Reports\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ReportForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('internship_id')
                    ->relationship('internship', 'title')
                    ->required(),
                Select::make('student_id')
                    ->relationship('student', 'name')
                    ->required(),
                TextInput::make('report_type')
                    ->required(),
                TextInput::make('title')
                    ->required(),
                TextInput::make('file_path')
                    ->required(),
                TextInput::make('file_name')
                    ->required(),
                TextInput::make('file_extension'),
                TextInput::make('file_size')
                    ->numeric(),
                TextInput::make('status')
                    ->required()
                    ->default('submitted'),
                DateTimePicker::make('submitted_at'),
                DateTimePicker::make('reviewed_at'),
                Textarea::make('review_notes')
                    ->columnSpanFull(),
            ]);
    }
}
