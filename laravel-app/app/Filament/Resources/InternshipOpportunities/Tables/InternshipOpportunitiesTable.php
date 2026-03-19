<?php

namespace App\Filament\Resources\InternshipOpportunities\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class InternshipOpportunitiesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('company.name')
                    ->label('الشركة')
                    ->searchable(),
                TextColumn::make('specialization.name')
                    ->label('التخصص')
                    ->searchable(),
                TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                TextColumn::make('city')
                    ->label('المدينة')
                    ->searchable(),
                TextColumn::make('seats_count')
                    ->label('المقاعد')
                    ->numeric()
                    ->sortable(),
                IconColumn::make('is_available')
                    ->label('متاحة')
                    ->boolean(),
                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->searchable(),
                TextColumn::make('application_deadline')
                    ->label('آخر موعد')
                    ->date()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'draft' => 'مسودة',
                        'published' => 'منشورة',
                        'closed' => 'مغلقة',
                    ]),
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
