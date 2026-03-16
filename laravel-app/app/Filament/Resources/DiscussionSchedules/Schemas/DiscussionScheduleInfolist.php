<?php

namespace App\Filament\Resources\DiscussionSchedules\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class DiscussionScheduleInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('specialization.name')
                    ->label('التخصص')
                    ->placeholder('-'),
                TextEntry::make('title')
                    ->label('العنوان'),
                TextEntry::make('description')
                    ->label('الوصف')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('academic_term')
                    ->label('الفصل الدراسي')
                    ->placeholder('-'),
                TextEntry::make('schedule_file_path')
                    ->label('ملف الجدول')
                    ->placeholder('-'),
                ImageEntry::make('schedule_image_path')
                    ->label('صورة الجدول')
                    ->placeholder('-'),
                TextEntry::make('published_at')
                    ->label('تاريخ النشر')
                    ->dateTime()
                    ->placeholder('-'),
                IconEntry::make('is_active')
                    ->label('نشط')
                    ->boolean(),
                TextEntry::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->label('تاريخ التحديث')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}

