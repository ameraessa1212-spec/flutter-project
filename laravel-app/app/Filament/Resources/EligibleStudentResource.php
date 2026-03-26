<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EligibleStudentResource\Pages;
use App\Models\EligibleStudent;
use Filament\Forms;
use Filament\Resources\Form;
use Filament\Resources\Resource;
use Filament\Resources\Table;
use Filament\Tables;

class EligibleStudentResource extends Resource
{
    protected static ?string $model = EligibleStudent::class;
    protected static ?string $navigationIcon = 'heroicon-o-identification';
    protected static ?string $navigationGroup = 'Students';
    protected static ?string $label = 'Eligible Student';
    protected static ?string $pluralLabel = 'Eligible Students';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
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
