<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Group;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)->schema([
                    Section::make('المعلومات الأساسية')
                        ->schema([
                            TextEntry::make('name')->label('الاسم الكامل')->placeholder('-'),
                            TextEntry::make('first_name')->label('الاسم الأول')->placeholder('-'),
                            TextEntry::make('last_name')->label('اسم العائلة')->placeholder('-'),
                            TextEntry::make('username')->label('اسم المستخدم')->placeholder('-'),
                            TextEntry::make('email')->label('البريد الإلكتروني')->placeholder('-'),
                            TextEntry::make('phone')->label('رقم الهاتف')->placeholder('-'),
                            TextEntry::make('role')->label('الدور')->badge(),
                            TextEntry::make('status')->label('الحالة')->badge(),
                        ])->columns(2)->columnSpan(2),
                        
                    Section::make('معلومات النظام')
                        ->schema([
                            TextEntry::make('created_at')->label('تاريخ الإنشاء')->dateTime()->placeholder('-'),
                            TextEntry::make('updated_at')->label('تاريخ التحديث')->dateTime()->placeholder('-'),
                            TextEntry::make('email_verified_at')->label('تاريخ تحقق البريد')->dateTime()->placeholder('-'),
                            TextEntry::make('phone_verified_at')->label('تاريخ تحقق الهاتف')->dateTime()->placeholder('-'),
                            TextEntry::make('last_login_at')->label('آخر تسجيل دخول')->dateTime()->placeholder('-'),
                        ])->columns(1)->columnSpan(1),
                ]),
                
                Section::make('الملف الشخصي للطالب (Student Profile)')
                    ->relationship('studentProfile')
                    ->visible(fn ($record) => data_get($record, 'role.value') === 'student' || data_get($record, 'role') === 'student')
                    ->schema([
                        Grid::make(3)->schema([
                            ImageEntry::make('profile_image_path')->label('الصورة الشخصية')->circular(),
                            Group::make()->schema([
                                TextEntry::make('university_name')->label('الجهة التعليمية (الجامعة)')->placeholder('-'),
                                TextEntry::make('specialization.name')->label('التخصص')->placeholder('-'),
                            ]),
                            Group::make()->schema([
                                TextEntry::make('student_number')->label('الرقم الجامعي')->placeholder('-'),
                                TextEntry::make('study_level')->label('المستوى الدراسي')->placeholder('-'),
                                TextEntry::make('expected_graduation_at')->label('تاريخ التخرج المتوقع')->date()->placeholder('-'),
                            ]),
                        ]),
                        Grid::make(1)->schema([
                            TextEntry::make('cv_file_path')
                                ->label('السيرة الذاتية')
                                ->formatStateUsing(fn ($state) => $state ? 'تنزيل / عرض' : 'لا يوجد')
                                ->url(fn ($state) => $state ? asset('storage/'.$state) : null, true)
                                ->color('primary')
                                ->icon('heroicon-o-document-arrow-down'),
                            TextEntry::make('bio')->label('النبذة الشخصية (Bio)')->placeholder('-'),
                        ])
                    ])
                    ->collapsible(),
            ]);
    }
}
