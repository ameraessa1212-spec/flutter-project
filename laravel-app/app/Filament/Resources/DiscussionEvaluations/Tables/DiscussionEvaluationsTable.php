<?php

namespace App\Filament\Resources\DiscussionEvaluations\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class DiscussionEvaluationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('discussion.student.name')
                    ->label('الطالب')
                    ->searchable(),
                TextColumn::make('discussion.internship.title')
                    ->label('التدريب')
                    ->searchable(),
                TextColumn::make('total_score')
                    ->label('الدرجة')
                    ->sortable(),
                TextColumn::make('decision')
                    ->label('القرار')
                    ->badge(),
                TextColumn::make('submitted_at')
                    ->label('تاريخ الإرسال')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
