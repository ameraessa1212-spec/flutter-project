<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use App\Models\Enums\ApplicationStatus;

class ApplicationsRelationManager extends RelationManager
{
    protected static string $relationship = 'applications';
    protected static ?string $title = 'طلبات التدريب (Applications)';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                Tables\Columns\TextColumn::make('opportunity.title')->label('اسم الفرصة')->searchable(),
                Tables\Columns\TextColumn::make('company.name')->label('الشركة')->searchable(),
                Tables\Columns\TextColumn::make('status')->label('الحالة')->badge(),
                Tables\Columns\TextColumn::make('created_at')->label('تاريخ التقديم')->dateTime(),
            ])
            ->filters([])
            ->headerActions([])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('عرض')
                    ->url(fn ($record) => route('filament.admin.resources.applications.view', $record))
                    ->icon('heroicon-m-eye')
            ])
            ->bulkActions([]);
    }
}
