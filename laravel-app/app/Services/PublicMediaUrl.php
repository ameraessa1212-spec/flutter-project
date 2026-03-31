<?php

namespace App\Services;

class PublicMediaUrl
{
    public static function forPath(?string $path): ?string
    {
        if (blank($path)) {
            return null;
        }

        return route('public.media.show', ['path' => ltrim($path, '/')]);
    }
}