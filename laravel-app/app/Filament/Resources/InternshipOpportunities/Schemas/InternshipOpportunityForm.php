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
                    ->label('الشركة')
                    ->relationship('company', 'name')
                    ->required(),
                Select::make('specialization_id')
                    ->label('التخصص')
                    ->relationship('specialization', 'name'),
                TextInput::make('title')
                    ->label('العنوان')
                    ->required(),
                Textarea::make('description')
                    ->label('الوصف')
                    ->required()
                    ->columnSpanFull(),
                TextInput::make('city')
                    ->label('المدينة'),
                TextInput::make('location_text')
                    ->label('الموقع'),
                TextInput::make('duration_text')
                    ->label('مدة التدريب'),
                TextInput::make('duration_days')
                    ->label('عدد الأيام')
                    ->numeric(),
                TextInput::make('seats_count')
                    ->label('عدد المقاعد')
                    ->numeric(),
                Toggle::make('is_available')
                    ->label('متاحة')
                    ->required(),
                Select::make('status')
                    ->label('الحالة')
                    ->required()
                    ->options([
                        'draft' => 'مسودة',
                        'published' => 'منشورة',
                        'closed' => 'مغلقة',
                    ])
                    ->default('draft'),
                DatePicker::make('start_date')
                    ->label('تاريخ البداية'),
                DatePicker::make('end_date')
                    ->label('تاريخ النهاية'),
                DatePicker::make('application_deadline')
                    ->label('آخر موعد للتقديم'),
                FileUpload::make('image_path')
                    ->label('الصورة')
                    ->image(),
            ]);
    }
}
