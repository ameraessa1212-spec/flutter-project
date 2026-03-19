<?php

namespace App\Filament\Resources\UserNotifications\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class UserNotificationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->label('المستخدم')
                    ->relationship('user', 'name')
                    ->required(),
                TextInput::make('title')
                    ->label('العنوان')
                    ->required(),
                Textarea::make('body')
                    ->label('المحتوى')
                    ->required()
                    ->columnSpanFull(),
                Select::make('type')
                    ->label('النوع')
                    ->required()
                    ->options([
                        'system' => 'نظام',
                        'application' => 'طلب',
                        'internship' => 'تدريب',
                        'report' => 'تقرير',
                        'schedule' => 'جدول',
                    ])
                    ->default('system'),
                TextInput::make('reference_type')
                    ->label('نوع المرجع'),
                TextInput::make('reference_id')
                    ->label('معرف المرجع')
                    ->numeric(),
                Toggle::make('is_read')
                    ->label('مقروء')
                    ->required(),
                DateTimePicker::make('read_at')
                    ->label('تاريخ القراءة'),
            ]);
    }
}
