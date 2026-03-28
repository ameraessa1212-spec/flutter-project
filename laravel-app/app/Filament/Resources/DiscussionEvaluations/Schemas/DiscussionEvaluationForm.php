<?php

namespace App\Filament\Resources\DiscussionEvaluations\Schemas;

use App\Models\ExaminerDiscussion;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class DiscussionEvaluationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('examiner_discussion_id')
                    ->label('موعد المناقشة')
                    ->relationship(
                        'discussion',
                        'id',
                        modifyQueryUsing: function ($query) {
                            $user = auth()->user();
                            if ($user?->hasRole('examiner')) {
                                $query->where('examiner_id', $user->id);
                            }
                        }
                    )
                    ->searchable()
                    ->getOptionLabelFromRecordUsing(fn (ExaminerDiscussion $record) => sprintf(
                        '%s - %s',
                        $record->student?->name ?? 'طالب',
                        $record->scheduled_at?->format('Y-m-d g:i A') ?? 'بدون موعد'
                    ))
                    ->reactive()
                    ->afterStateUpdated(function ($state, callable $set) {
                        if (! $state) {
                            return;
                        }

                        $discussion = ExaminerDiscussion::find($state);
                        if (! $discussion) {
                            return;
                        }

                        $set('internship_id', $discussion->internship_id);
                        $set('student_id', $discussion->student_id);
                        $set('examiner_id', $discussion->examiner_id);
                    })
                    ->required(),
                Hidden::make('internship_id'),
                Hidden::make('student_id'),
                Hidden::make('examiner_id'),
                TextInput::make('total_score')
                    ->label('الدرجة النهائية')
                    ->numeric(),
                Select::make('decision')
                    ->label('القرار')
                    ->options([
                        'pass' => 'ناجح',
                        'fail' => 'راسب',
                        'postponed' => 'مؤجل',
                        'pending' => 'قيد الانتظار',
                    ])
                    ->default('pending')
                    ->required(),
                Textarea::make('rubric_scores')
                    ->label('تفاصيل الدرجات')
                    ->helperText('اكتب تفاصيل المعايير بصيغة JSON عند الحاجة.')
                    ->columnSpanFull(),
                Textarea::make('notes')
                    ->label('ملاحظات الممتحن')
                    ->columnSpanFull(),
                Toggle::make('visible_to_supervisor')
                    ->label('إظهار للمشرف')
                    ->default(true),
                Toggle::make('visible_to_company')
                    ->label('إظهار للجهة التدريبية')
                    ->default(true),
                Toggle::make('visible_to_student')
                    ->label('إظهار للطالب')
                    ->default(false),
                DateTimePicker::make('submitted_at')
                    ->label('تاريخ الإرسال'),
            ]);
    }
}
