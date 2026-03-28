<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\ExaminerAlertsWidget;
use App\Filament\Widgets\ExaminerPendingEvaluationsWidget;
use App\Filament\Widgets\ExaminerUpcomingDiscussionsWidget;
use App\Filament\Widgets\ExaminerUrgentDiscussionsWidget;
use Filament\Pages\Dashboard;
use Filament\Panel; // <-- Added this import
use UnitEnum;
use BackedEnum;

class ExaminerDashboard extends Dashboard
{
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-clipboard-document-check';
    protected static ?string $navigationLabel = 'لوحة الممتحن';
    protected static ?string $title = 'لوحة الممتحن';
    protected static string|UnitEnum|null $navigationGroup = 'الممتحن';
    
    // Dashboards use $routePath instead of $slug
    protected static string $routePath = 'examiner-dashboard';

    // FIX: Match the parent signature exactly by accepting the Panel argument
    public static function getRelativeRouteName(Panel $panel): string
    {
        return 'examiner-dashboard';
    }

    public static function canAccess(): bool
    {
        return auth()->user()?->can('examiner.dashboard') ?? false;
    }

    public function getWidgets(): array
    {
        return [
            ExaminerAlertsWidget::class,
            ExaminerUpcomingDiscussionsWidget::class,
            ExaminerUrgentDiscussionsWidget::class,
            ExaminerPendingEvaluationsWidget::class,
        ];
    }

    public function getColumns(): int|array
    {
        return 3;
    }
}