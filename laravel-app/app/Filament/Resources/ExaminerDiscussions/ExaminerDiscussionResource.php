<?php

namespace App\Filament\Resources\ExaminerDiscussions;

use App\Filament\Resources\ExaminerDiscussions\Pages\CreateExaminerDiscussion;
use App\Filament\Resources\ExaminerDiscussions\Pages\EditExaminerDiscussion;
use App\Filament\Resources\ExaminerDiscussions\Pages\ListExaminerDiscussions;
use App\Filament\Resources\ExaminerDiscussions\Pages\ViewExaminerDiscussion;
use App\Filament\Resources\ExaminerDiscussions\Schemas\ExaminerDiscussionForm;
use App\Filament\Resources\ExaminerDiscussions\Schemas\ExaminerDiscussionInfolist;
use App\Filament\Resources\ExaminerDiscussions\Tables\ExaminerDiscussionsTable;
use App\Models\ExaminerDiscussion;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class ExaminerDiscussionResource extends Resource
{
    protected static ?string $model = ExaminerDiscussion::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCalendarDays;

    protected static ?string $navigationLabel = 'مواعيد المناقشة';

    protected static string|UnitEnum|null $navigationGroup = 'الممتحن';

    protected static ?int $navigationSort = 1;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('examiner.discussions.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('examiner.discussions.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('examiner.discussions.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return ExaminerDiscussionForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return ExaminerDiscussionInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ExaminerDiscussionsTable::configure($table);
    }

    public static function getEloquentQuery(): Builder
    {
        $query = parent::getEloquentQuery();
        $user = auth()->user();

        if ($user?->hasRole('examiner')) {
            $query->where('examiner_id', $user->id);
        }

        return $query;
    }

    public static function getPages(): array
    {
        return [
            'index' => ListExaminerDiscussions::route('/'),
            'create' => CreateExaminerDiscussion::route('/create'),
            'view' => ViewExaminerDiscussion::route('/{record}'),
            'edit' => EditExaminerDiscussion::route('/{record}/edit'),
        ];
    }
}
