<?php

namespace App\Filament\Resources\ExaminerDiscussions\Schemas;

use App\Models\ExaminerDiscussion;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class ExaminerDiscussionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('internship_id')
                    ->label('التدريب')
                    ->relationship('internship', 'title')
                    ->required(),
                Select::make('student_id')
                    ->label('الطالب')
                    ->relationship('student', 'name')
                    ->required(),
                Select::make('examiner_id')
                    ->label('الممتحن')
                    ->relationship('examiner', 'name')
                    ->required()
                    ->default(fn () => auth()->id())
                    ->disabled(fn () => auth()->user()?->hasRole('examiner'))
                    ->dehydrated(),
                DateTimePicker::make('scheduled_at')
                    ->label('موعد المناقشة'),
                TextInput::make('location')
                    ->label('الموقع'),
                TextInput::make('meeting_link')
                    ->label('رابط الاجتماع')
                    ->url(),
                Select::make('status')
                    ->label('الحالة')
                    ->options([
                        'scheduled' => 'مجدولة',
                        'completed' => 'مكتملة',
                        'canceled' => 'ملغاة',
                    ])
                    ->default('scheduled')
                    ->required(),
                Toggle::make('is_urgent')
                    ->label('عاجل')
                    ->default(false),
                Textarea::make('notes')
                    ->label('ملاحظات')
                    ->columnSpanFull(),
            ]);
    }
}
