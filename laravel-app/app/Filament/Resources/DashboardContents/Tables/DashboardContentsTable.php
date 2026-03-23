<?php

namespace App\Filament\Resources\DashboardContents\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class DashboardContentsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('sort_order')
            ->columns([
                TextColumn::make('type')->label('النوع')->badge(),
                TextColumn::make('title')->label('العنوان')->searchable()->limit(40),
                TextColumn::make('badge')->label('الشارة')->toggleable(),
                TextColumn::make('sort_order')->label('الترتيب')->sortable(),
                ImageColumn::make('image_path')->label('صورة مرفوعة')->disk('public')->square(),
                TextColumn::make('image_asset')->label('صورة من الأصول')->limit(30)->toggleable(),
                IconColumn::make('is_active')->label('نشط')->boolean(),
                TextColumn::make('updated_at')->label('آخر تحديث')->dateTime()->sortable(),
            ])
            ->filters([
                SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'slider' => 'سلايدر',
                        'tip' => 'نصيحة',
                        'announcement' => 'إعلان',
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