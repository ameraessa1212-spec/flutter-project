<?php

namespace App\Filament\Widgets;

use App\Models\ExaminerDiscussion;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ExaminerPendingEvaluationsWidget extends BaseWidget
{
    protected int|string|array $columnSpan = 1;

    public static function canView(): bool
    {
        return auth()->user()?->can('examiner.dashboard') ?? false;
    }

    protected function getStats(): array
    {
        $pendingCount = ExaminerDiscussion::query()
            ->where('examiner_id', auth()->id())
            ->where('status', 'completed')
            ->whereDoesntHave('evaluation')
            ->count();

        return [
            Stat::make('التقييمات المطلوبة', $pendingCount)
                ->description('تقييمات بانتظار الإرسال')
                ->color('primary'),
        ];
    }
}
