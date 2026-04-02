<?php

namespace App\Filament\Resources\ExaminerDiscussions\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ExaminerDiscussionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('student.name')
                    ->label('الطالب')
                    ->searchable(),
                TextColumn::make('internship.title')
                    ->label('التدريب')
                    ->searchable(),
                TextColumn::make('scheduled_at')
                    ->label('الموعد')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge(),
                IconColumn::make('is_urgent')
                    ->label('عاجل')
                    ->boolean(),
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
