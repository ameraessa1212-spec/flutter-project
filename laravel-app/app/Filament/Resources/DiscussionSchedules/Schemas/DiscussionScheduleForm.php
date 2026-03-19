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
                    ->label('التخصص')
                    ->relationship('specialization', 'name'),
                TextInput::make('title')
                    ->label('العنوان')
                    ->required(),
                Textarea::make('description')
                    ->label('الوصف')
                    ->columnSpanFull(),
                TextInput::make('academic_term')
                    ->label('الفصل الدراسي'),
                TextInput::make('schedule_file_path')
                    ->label('مسار ملف الجدول'),
                FileUpload::make('schedule_image_path')
                    ->label('صورة الجدول')
                    ->image(),
                DateTimePicker::make('published_at')
                    ->label('تاريخ النشر'),
                Toggle::make('is_active')
                    ->label('نشط')
                    ->required(),
            ]);
    }
}
