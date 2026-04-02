<?php

namespace App\Filament\Resources\InternshipOpportunities\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ApplicationsRelationManager extends RelationManager
{
    protected static string $relationship = 'applications';
    protected static ?string $title = 'المتقدمون (Applications)';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                Tables\Columns\TextColumn::make('student.name')->label('الطالب')->searchable(),
                Tables\Columns\TextColumn::make('status')->label('حالة الطلب')->badge(),
                Tables\Columns\TextColumn::make('created_at')->label('تاريخ التقديم')->dateTime(),
            ])
            ->filters([])
            ->headerActions([])
            ->actions([])
            ->bulkActions([]);
    }
}
