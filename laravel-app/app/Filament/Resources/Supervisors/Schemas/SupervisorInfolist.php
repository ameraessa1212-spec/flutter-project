<?php

namespace App\Filament\Resources\Supervisors\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class SupervisorInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(2)->schema([
                    Section::make('المعلومات الأساسية')
                        ->schema([
                            TextEntry::make('name')->label('الاسم'),
                            TextEntry::make('user.name')->label('حساب المستخدم')->placeholder('-'),
                            TextEntry::make('phone')->label('رقم الهاتف')->placeholder('-')->icon('heroicon-m-phone'),
                            TextEntry::make('email')->label('البريد الإلكتروني')->placeholder('-')->icon('heroicon-m-envelope'),
                        ])->columnSpan(1),
                        
                    Section::make('معلومات العمل')
                        ->schema([
                            TextEntry::make('type')->label('النوع')->badge(),
                            TextEntry::make('company.name')->label('المرجع (الشركة / الجامعة)')->placeholder('أكاديمي / غير محدد'),
                            TextEntry::make('department')->label('القسم')->placeholder('-'),
                            IconEntry::make('is_active')->label('نشط')->boolean(),
                        ])->columnSpan(1),
                ]),
            ]);
    }
}
