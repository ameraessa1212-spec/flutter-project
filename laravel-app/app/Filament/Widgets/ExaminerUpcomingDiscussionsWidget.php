<?php

namespace App\Filament\Widgets;

use App\Models\ExaminerDiscussion;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class ExaminerUpcomingDiscussionsWidget extends BaseWidget
{
    protected static ?string $heading = 'المواعيد القادمة';

    protected int|string|array $columnSpan = 2;

    public static function canView(): bool
    {
        return auth()->user()?->can('examiner.dashboard') ?? false;
    }

    protected function getTableQuery(): Builder
    {
        return ExaminerDiscussion::query()
            ->where('examiner_id', auth()->id())
            ->where('status', 'scheduled')
            ->whereNotNull('scheduled_at')
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
                ->dateTime()
                ->sortable(),
            IconColumn::make('is_urgent')
                ->label('عاجل')
                ->boolean(),
        ];
    }
}
