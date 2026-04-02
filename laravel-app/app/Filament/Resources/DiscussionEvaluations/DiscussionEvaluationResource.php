<?php

namespace App\Filament\Resources\DiscussionEvaluations;

use App\Filament\Resources\DiscussionEvaluations\Pages\CreateDiscussionEvaluation;
use App\Filament\Resources\DiscussionEvaluations\Pages\EditDiscussionEvaluation;
use App\Filament\Resources\DiscussionEvaluations\Pages\ListDiscussionEvaluations;
use App\Filament\Resources\DiscussionEvaluations\Pages\ViewDiscussionEvaluation;
use App\Filament\Resources\DiscussionEvaluations\Schemas\DiscussionEvaluationForm;
use App\Filament\Resources\DiscussionEvaluations\Schemas\DiscussionEvaluationInfolist;
use App\Filament\Resources\DiscussionEvaluations\Tables\DiscussionEvaluationsTable;
use App\Models\DiscussionEvaluation;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class DiscussionEvaluationResource extends Resource
{
    protected static ?string $model = DiscussionEvaluation::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedClipboardDocumentList;

    protected static ?string $navigationLabel = 'تقييمات المناقشة';

    protected static string|UnitEnum|null $navigationGroup = 'الممتحن';

    protected static ?int $navigationSort = 2;

    public static function canViewAny(): bool
    {
        return auth()->user()?->can('examiner.evaluations.view') ?? false;
    }

    public static function canCreate(): bool
    {
        return auth()->user()?->can('examiner.evaluations.manage') ?? false;
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->can('examiner.evaluations.manage') ?? false;
    }

    public static function form(Schema $schema): Schema
    {
        return DiscussionEvaluationForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return DiscussionEvaluationInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return DiscussionEvaluationsTable::configure($table);
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
            'index' => ListDiscussionEvaluations::route('/'),
            'create' => CreateDiscussionEvaluation::route('/create'),
            'view' => ViewDiscussionEvaluation::route('/{record}'),
            'edit' => EditDiscussionEvaluation::route('/{record}/edit'),
        ];
    }
}
