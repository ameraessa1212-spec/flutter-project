<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EligibleStudentResource\Pages;
use App\Models\EligibleStudent;
use Filament\Forms;
use Filament\Schemas\Schema; // <-- New Schema Import
use Filament\Resources\Resource;
use Filament\Tables\Table;   // <-- New Table Import
use Filament\Tables;

class EligibleStudentResource extends Resource
{
    protected static ?string $model = EligibleStudent::class;
    
    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-identification';
    protected static \UnitEnum|string|null $navigationGroup = 'Students';
    
    protected static ?string $label = 'Eligible Student';
    protected static ?string $pluralLabel = 'Eligible Students';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([ // <-- Changed from schema() to components()
                Forms\Components\TextInput::make('student_number')
                    ->required()
                    ->unique(ignoreRecord: true),
                Forms\Components\TextInput::make('name'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('student_number')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                // ...
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListEligibleStudents::route('/'),
            'create' => Pages\CreateEligibleStudent::route('/create'),
            'edit' => Pages\EditEligibleStudent::route('/{record}/edit'),
        ];
    }
}