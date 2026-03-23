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
                ->live()
                ->required()
                ->afterStateUpdated(function ($state, callable $set): void {
                    if ($state !== 'slider') {
                        $set('image_asset', null);
                        $set('image_path', null);
                    }

                    if (! in_array($state, ['tip', 'announcement'], true)) {
                        $set('icon_key', null);
                    }

                    if ($state !== 'announcement') {
                        $set('badge', null);
                    }
                }),
            TextInput::make('title')
                ->label('العنوان')
                ->required()
                ->maxLength(255),
            Textarea::make('subtitle')
                ->label('الوصف')
                ->required(fn (callable $get): bool => in_array($get('type'), ['slider', 'tip', 'announcement'], true))
                ->rows(3)
                ->columnSpanFull(),
            TextInput::make('image_asset')
                ->label('مسار صورة من الأصول')
                ->helperText('خاص بالسلايدر. اتركه فارغاً إذا رفعت صورة بدلاً منه. مثال: assets/images/madar.JPG')
                ->visible(fn (callable $get): bool => $get('type') === 'slider')
                ->required(fn (callable $get): bool => $get('type') === 'slider' && blank($get('image_path')))
                ->maxLength(255),
            FileUpload::make('image_path')
                ->label('صورة مرفوعة')
                ->disk('public')
                ->directory('dashboard-content')
                ->image()
                ->imageEditor()
                ->visible(fn (callable $get): bool => $get('type') === 'slider')
                ->required(fn (callable $get): bool => $get('type') === 'slider' && blank($get('image_asset')))
                ->helperText('خاص بالسلايدر. ارفع صورة أو أدخل مسار صورة من الأصول.'),
            TextInput::make('icon_key')
                ->label('مفتاح الأيقونة')
                ->helperText('مثل: article, track_changes, schedule, campaign, notifications')
                ->visible(fn (callable $get): bool => in_array($get('type'), ['tip', 'announcement'], true))
                ->required(fn (callable $get): bool => in_array($get('type'), ['tip', 'announcement'], true))
                ->maxLength(64),
            TextInput::make('badge')
                ->label('شارة')
                ->helperText('اختياري للإعلانات فقط.')
                ->visible(fn (callable $get): bool => $get('type') === 'announcement')
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