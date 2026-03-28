<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class InternshipsRelationManager extends RelationManager
{
    protected static string $relationship = 'internships';
    protected static ?string $title = 'التدريبات القائمة (Internships)';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                Tables\Columns\TextColumn::make('opportunity.title')->label('الفرصة')->searchable(),
                Tables\Columns\TextColumn::make('company.name')->label('الشركة')->searchable(),
                Tables\Columns\TextColumn::make('status')->label('حالة التدريب')->badge(),
                Tables\Columns\TextColumn::make('start_date')->label('تاريخ البداية')->date(),
                Tables\Columns\TextColumn::make('end_date')->label('تاريخ النهاية')->date(),
            ])
            ->filters([])
            ->headerActions([])
            ->actions([])
            ->bulkActions([]);
    }
}
