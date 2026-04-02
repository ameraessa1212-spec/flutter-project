<?php

use App\Http\Controllers\PublicMediaController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/media/public/{path}', [PublicMediaController::class, 'show'])
    ->where('path', '.*')
    ->name('public.media.show');

Route::options('/media/public/{path}', [PublicMediaController::class, 'options'])
    ->where('path', '.*');
