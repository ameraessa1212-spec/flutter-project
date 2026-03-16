<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('first_name')
                    ->required()
                    ->maxLength(100),
                TextInput::make('last_name')
                    ->required()
                    ->maxLength(100),
                TextInput::make('name')
                    ->required(),
                TextInput::make('username')
                    ->required()
                    ->maxLength(100)
                    ->unique(ignoreRecord: true),
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required()
                    ->unique(ignoreRecord: true),
                TextInput::make('phone')
                    ->tel()
                    ->required()
                    ->maxLength(20)
                    ->unique(ignoreRecord: true),
                TextInput::make('password')
                    ->password()
                    ->revealable()
                    ->minLength(8)
                    ->dehydrateStateUsing(fn ($state) => filled($state) ? bcrypt($state) : null)
                    ->dehydrated(fn ($state) => filled($state))
                    ->required(fn (string $operation): bool => $operation === 'create'),
                Select::make('role')
                    ->required()
                    ->options([
                        'student' => 'Student',
                        'super_admin' => 'Super Admin',
                        'operations' => 'Operations',
                        'supervisor' => 'Supervisor',
                        'content_manager' => 'Content Manager',
                        'support' => 'Support',
                    ])
                    ->default('student'),
                Select::make('status')
                    ->required()
                    ->options([
                        'pending' => 'Pending',
                        'active' => 'Active',
                        'inactive' => 'Inactive',
                    ])
                    ->default('pending'),
                DateTimePicker::make('email_verified_at'),
                DateTimePicker::make('phone_verified_at'),
                DateTimePicker::make('last_login_at'),
            ]);
    }
}
