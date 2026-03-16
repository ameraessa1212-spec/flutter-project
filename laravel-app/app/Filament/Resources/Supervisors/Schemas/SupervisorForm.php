<?php

namespace App\Filament\Resources\Supervisors\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class SupervisorForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->label('حساب المستخدم')
                    ->relationship('user', 'name'),
                Select::make('company_id')
                    ->label('الشركة')
                    ->relationship('company', 'name'),
                TextInput::make('name')
                    ->label('الاسم')
                    ->required(),
                TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->tel(),
                TextInput::make('email')
                    ->label('البريد الإلكتروني')
                    ->email(),
                Select::make('type')
                    ->label('النوع')
                    ->required()
                    ->options([
                        'academic' => 'أكاديمي',
                        'field' => 'ميداني',
                    ])
                    ->default('academic'),
                TextInput::make('department')
                    ->label('القسم'),
                Toggle::make('is_active')
                    ->label('نشط')
                    ->required()
                    ->default(true),
            ]);
    }
}
