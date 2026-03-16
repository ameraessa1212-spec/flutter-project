<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('first_name')
                    ->label('الاسم الأول')
                    ->required()
                    ->maxLength(100),
                TextInput::make('last_name')
                    ->label('اسم العائلة')
                    ->required()
                    ->maxLength(100),
                TextInput::make('name')
                    ->label('الاسم الكامل')
                    ->required(),
                TextInput::make('username')
                    ->label('اسم المستخدم')
                    ->required()
                    ->maxLength(100)
                    ->unique(ignoreRecord: true),
                TextInput::make('email')
                    ->label('البريد الإلكتروني')
                    ->email()
                    ->required()
                    ->unique(ignoreRecord: true),
                TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->tel()
                    ->required()
                    ->maxLength(20)
                    ->unique(ignoreRecord: true),
                TextInput::make('password')
                    ->label('كلمة المرور')
                    ->password()
                    ->revealable()
                    ->minLength(8)
                    ->dehydrateStateUsing(fn ($state) => filled($state) ? bcrypt($state) : null)
                    ->dehydrated(fn ($state) => filled($state))
                    ->required(fn (string $operation): bool => $operation === 'create'),
                Select::make('role')
                    ->label('الدور')
                    ->required()
                    ->options([
                        'student' => 'طالب',
                        'super_admin' => 'مدير النظام',
                        'operations' => 'العمليات',
                        'supervisor' => 'مشرف',
                        'content_manager' => 'مدير المحتوى',
                        'support' => 'الدعم الفني',
                    ])
                    ->default('student'),
                Select::make('status')
                    ->label('الحالة')
                    ->required()
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                    ])
                    ->default('pending'),
                DateTimePicker::make('email_verified_at')
                    ->label('تاريخ تحقق البريد'),
                DateTimePicker::make('phone_verified_at')
                    ->label('تاريخ تحقق الهاتف'),
                DateTimePicker::make('last_login_at')
                    ->label('آخر تسجيل دخول'),
            ]);
    }
}
