<?php

namespace App\Filament\Resources\DiscussionSchedules\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class DiscussionScheduleForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('specialization_id')
                    ->relationship('specialization', 'name'),
                TextInput::make('title')
                    ->required(),
                Textarea::make('description')
                    ->columnSpanFull(),
                TextInput::make('academic_term'),
                TextInput::make('schedule_file_path'),
                FileUpload::make('schedule_image_path')
                    ->image(),
                DateTimePicker::make('published_at'),
                Toggle::make('is_active')
                    ->required(),
            ]);
    }
}
