<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use UnitEnum;
use BackedEnum;

class SupervisorChat extends Page
{
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static ?string $navigationLabel = 'المحادثات';
    protected static ?string $title = 'المحادثات المباشرة';
    protected static string|UnitEnum|null $navigationGroup = 'التواصل';
    
    protected string $view = 'filament.pages.supervisor-chat';

    public static function canAccess(): bool
    {
        return auth()->user()->hasAnyRole(['super_admin', 'supervisor']);
    }
}

