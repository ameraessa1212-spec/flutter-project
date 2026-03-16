<?php

namespace App\Filament\Resources\Applications\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ApplicationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('student_id')
                    ->label('الطالب')
                    ->relationship('student', 'name')
                    ->required(),
                Select::make('opportunity_id')
                    ->label('فرصة التدريب')
                    ->relationship('opportunity', 'title')
                    ->required(),
                Select::make('company_id')
                    ->label('الشركة')
                    ->relationship('company', 'name')
                    ->required(),
                TextInput::make('full_name_snapshot')
                    ->label('الاسم الكامل')
                    ->required(),
                TextInput::make('phone_snapshot')
                    ->label('رقم الهاتف')
                    ->tel(),
                TextInput::make('email_snapshot')
                    ->label('البريد الإلكتروني')
                    ->email(),
                TextInput::make('university_snapshot')
                    ->label('الجامعة'),
                TextInput::make('major_snapshot')
                    ->label('التخصص'),
                TextInput::make('level_snapshot')
                    ->label('المستوى الدراسي'),
                TextInput::make('cv_file_path')
                    ->label('مسار السيرة الذاتية'),
                Textarea::make('notes')
                    ->label('ملاحظات')
                    ->columnSpanFull(),
                Select::make('status')
                    ->label('الحالة')
                    ->required()
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                    ])
                    ->default('pending'),
                DateTimePicker::make('submitted_at')
                    ->label('تاريخ التقديم'),
                DateTimePicker::make('reviewed_at')
                    ->label('تاريخ المراجعة'),
                Select::make('reviewed_by')
                    ->label('راجعه')
                    ->relationship('reviewer', 'name'),
                Textarea::make('review_notes')
                    ->label('ملاحظات المراجعة')
                    ->columnSpanFull(),
            ]);
    }
}
