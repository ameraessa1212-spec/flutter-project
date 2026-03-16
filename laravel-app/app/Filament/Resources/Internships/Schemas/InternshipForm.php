<?php

namespace App\Filament\Resources\Internships\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class InternshipForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('application_id')
                    ->label('الطلب')
                    ->relationship('application', 'id')
                    ->required(),
                Select::make('student_id')
                    ->label('الطالب')
                    ->relationship('student', 'name')
                    ->required(),
                Select::make('company_id')
                    ->label('الشركة')
                    ->relationship('company', 'name')
                    ->required(),
                Select::make('opportunity_id')
                    ->label('فرصة التدريب')
                    ->relationship('opportunity', 'title'),
                Select::make('supervisor_id')
                    ->label('المشرف')
                    ->relationship('supervisor', 'name'),
                TextInput::make('title')
                    ->label('العنوان')
                    ->required(),
                Select::make('status')
                    ->label('الحالة')
                    ->required()
                    ->options([
                        'active' => 'نشط',
                        'completed' => 'مكتمل',
                        'cancelled' => 'ملغى',
                    ])
                    ->default('active'),
                DatePicker::make('start_date')
                    ->label('تاريخ البداية'),
                DatePicker::make('end_date')
                    ->label('تاريخ النهاية'),
                DatePicker::make('report_due_date')
                    ->label('موعد تسليم التقرير'),
                Textarea::make('notes')
                    ->label('ملاحظات')
                    ->columnSpanFull(),
            ]);
    }
}
