<?php

namespace App\Filament\Widgets;

use App\Models\ExaminerDiscussion;
use Filament\Tables\Columns\TextColumn;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class ExaminerUrgentDiscussionsWidget extends BaseWidget
{
    protected static ?string $heading = 'مهام عاجلة';

    protected int|string|array $columnSpan = 1;

    public static function canView(): bool
    {
        return auth()->user()?->can('examiner.dashboard') ?? false;
    }

    protected function getTableQuery(): Builder
    {
        return ExaminerDiscussion::query()
            ->where('examiner_id', auth()->id())
            ->where('status', 'scheduled')
            ->where('is_urgent', true)
            ->orderBy('scheduled_at');
    }

    protected function getTableColumns(): array
    {
        return [
            TextColumn::make('student.name')
                ->label('الطالب')
                ->searchable(),
            TextColumn::make('scheduled_at')
                ->label('الموعد')
                ->dateTime(),
        ];
    }
}
