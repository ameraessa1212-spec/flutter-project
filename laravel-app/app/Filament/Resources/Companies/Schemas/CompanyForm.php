<?php

namespace App\Filament\Resources\Companies\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class CompanyForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label('اسم الشركة')
                    ->required(),
                TextInput::make('slug')
                    ->label('المعرف المختصر')
                    ->required(),
                Textarea::make('description')
                    ->label('الوصف')
                    ->columnSpanFull(),
                TextInput::make('logo_path')
                    ->label('مسار الشعار'),
                TextInput::make('website_url')
                    ->label('الموقع الإلكتروني')
                    ->url(),
                TextInput::make('map_url')
                    ->label('رابط الخريطة')
                    ->url(),
                TextInput::make('city')
                    ->label('المدينة'),
                TextInput::make('address')
                    ->label('العنوان'),
                TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->tel(),
                TextInput::make('email')
                    ->label('البريد الإلكتروني')
                    ->email(),
                Toggle::make('is_active')
                    ->label('نشطة')
                    ->required(),
            ]);
    }
}
