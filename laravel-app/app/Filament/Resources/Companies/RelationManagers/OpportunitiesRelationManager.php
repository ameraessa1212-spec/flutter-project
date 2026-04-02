<?php

namespace App\Filament\Resources\Companies\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class OpportunitiesRelationManager extends RelationManager
{
    protected static string $relationship = 'opportunities';
    protected static ?string $title = 'فرص التدريب (Opportunities)';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('title')
            ->columns([
                Tables\Columns\TextColumn::make('title')->label('عنوان الفرصة')->searchable(),
                Tables\Columns\TextColumn::make('specialization.name')->label('التخصص'),
                Tables\Columns\TextColumn::make('status')->label('الحالة')->badge(),
                Tables\Columns\TextColumn::make('available_seats')->label('المقاعد الإجمالية'),
            ])
            ->filters([])
            ->headerActions([])
            ->actions([])
            ->bulkActions([]);
    }
}
