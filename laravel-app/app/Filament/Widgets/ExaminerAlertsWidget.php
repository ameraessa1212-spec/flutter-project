<?php

namespace App\Filament\Widgets;

use App\Models\UserNotification;
use Filament\Tables\Columns\TextColumn;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class ExaminerAlertsWidget extends BaseWidget
{
    protected static ?string $heading = 'تنبيهات هامة';

    protected int|string|array $columnSpan = 'full';

    public static function canView(): bool
    {
        return auth()->user()?->can('examiner.dashboard') ?? false;
    }

    protected function getTableQuery(): Builder
    {
        return UserNotification::query()
            ->where('user_id', auth()->id())
            ->where('is_read', false)
            ->latest();
    }

    protected function getTableColumns(): array
    {
        return [
            TextColumn::make('title')
                ->label('العنوان')
                ->searchable(),
            TextColumn::make('body')
                ->label('التفاصيل')
                ->limit(80),
            TextColumn::make('created_at')
                ->label('التاريخ')
                ->dateTime(),
        ];
    }
}
