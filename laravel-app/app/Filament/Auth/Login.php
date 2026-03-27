<?php

namespace App\Filament\Auth;

use Filament\Pages\Auth\Login as BaseLogin;

class Login extends Login
{
    protected function getHeading(): string
    {
        return 'مرحباً بك 👋';
    }
}