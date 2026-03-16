<?php

namespace App\Filament\Resources\Applications\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ApplicationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('student.name')
                    ->searchable(),
                TextColumn::make('opportunity.title')
                    ->searchable(),
                TextColumn::make('company.name')
                    ->searchable(),
                TextColumn::make('full_name_snapshot')
                    ->searchable(),
                TextColumn::make('phone_snapshot')
                    ->searchable(),
                TextColumn::make('email_snapshot')
                    ->searchable(),
                TextColumn::make('university_snapshot')
                    ->searchable(),
                TextColumn::make('major_snapshot')
                    ->searchable(),
                TextColumn::make('level_snapshot')
                    ->searchable(),
                TextColumn::make('cv_file_path')
                    ->searchable(),
                TextColumn::make('status')
                    ->searchable(),
                TextColumn::make('submitted_at')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('reviewed_at')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('reviewed_by')
                    ->numeric()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
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
