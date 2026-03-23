<?php

namespace App\Filament\Resources\DashboardContents\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class DashboardContentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('type')
                ->label('النوع')
                ->options([
                    'slider' => 'سلايدر',
                    'tip' => 'نصيحة',
                    'announcement' => 'إعلان',
                ])
                ->required(),
            TextInput::make('title')
                ->label('العنوان')
                ->required()
                ->maxLength(255),
            Textarea::make('subtitle')
                ->label('الوصف')
                ->rows(3)
                ->columnSpanFull(),
            TextInput::make('image_asset')
                ->label('مسار صورة من الأصول')
                ->helperText('مثال: assets/images/madar.JPG')
                ->maxLength(255),
            FileUpload::make('image_path')
                ->label('صورة مرفوعة')
                ->disk('public')
                ->directory('dashboard-content')
                ->image()
                ->imageEditor(),
            TextInput::make('icon_key')
                ->label('مفتاح الأيقونة')
                ->helperText('مثل: article, track_changes, schedule, campaign, notifications')
                ->maxLength(64),
            TextInput::make('badge')
                ->label('شارة')
                ->maxLength(64),
            TextInput::make('sort_order')
                ->label('الترتيب')
                ->numeric()
                ->default(0)
                ->required(),
            Toggle::make('is_active')
                ->label('نشط')
                ->default(true)
                ->required(),
        ]);
    }
}