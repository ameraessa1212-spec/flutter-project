<?php

namespace App\Filament\Resources\DashboardContents\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class DashboardContentInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            TextEntry::make('type')->label('النوع'),
            TextEntry::make('title')->label('العنوان'),
            TextEntry::make('subtitle')->label('الوصف'),
            TextEntry::make('image_asset')->label('صورة من الأصول'),
            ImageEntry::make('image_path')->label('الصورة المرفوعة')->disk('public'),
            TextEntry::make('icon_key')->label('مفتاح الأيقونة'),
            TextEntry::make('badge')->label('الشارة'),
            TextEntry::make('sort_order')->label('الترتيب'),
            IconEntry::make('is_active')->label('نشط')->boolean(),
        ]);
    }
}