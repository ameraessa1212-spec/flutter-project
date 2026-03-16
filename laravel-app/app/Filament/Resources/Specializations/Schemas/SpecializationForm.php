<?php

namespace App\Filament\Resources\Specializations\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class SpecializationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label('اسم التخصص')
                    ->required()
                    ->unique(ignoreRecord: true),
                TextInput::make('code')
                    ->label('الرمز')
                    ->unique(ignoreRecord: true),
                Toggle::make('is_active')
                    ->label('نشط')
                    ->required()
                    ->default(true),
            ]);
    }
}
