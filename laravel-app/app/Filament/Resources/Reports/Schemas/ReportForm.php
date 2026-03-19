<?php

namespace App\Filament\Resources\Reports\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ReportForm
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
                Select::make('report_type')
                    ->label('نوع التقرير')
                    ->required()
                    ->options([
                        'weekly' => 'أسبوعي',
                        'monthly' => 'شهري',
                        'final' => 'نهائي',
                    ]),
                TextInput::make('title')
                    ->label('العنوان')
                    ->required(),
                TextInput::make('file_path')
                    ->label('مسار الملف')
                    ->required(),
                TextInput::make('file_name')
                    ->label('اسم الملف')
                    ->required(),
                TextInput::make('file_extension')
                    ->label('امتداد الملف'),
                TextInput::make('file_size')
                    ->label('حجم الملف')
                    ->numeric(),
                Select::make('status')
                    ->label('الحالة')
                    ->required()
                    ->options([
                        'submitted' => 'مقدم',
                        'under_review' => 'قيد المراجعة',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                    ])
                    ->default('submitted'),
                DateTimePicker::make('submitted_at')
                    ->label('تاريخ التقديم'),
                DateTimePicker::make('reviewed_at')
                    ->label('تاريخ المراجعة'),
                Textarea::make('review_notes')
                    ->label('ملاحظات المراجعة')
                    ->columnSpanFull(),
            ]);
    }
}
