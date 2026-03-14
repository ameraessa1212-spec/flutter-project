<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Supabase Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your Supabase connection settings.
    |
    */

    'url' => rtrim((string) env('SUPABASE_URL', ''), '/'),

    'key' => env('SUPABASE_SERVICE_ROLE_KEY', env('SUPABASE_SECRET', '')),

    'secret' => env('SUPABASE_SERVICE_ROLE_KEY', env('SUPABASE_SECRET', '')),

    'publishable_key' => env('SUPABASE_PUBLISHABLE_KEY', env('SUPABASE_KEY', '')),

    /*
    |--------------------------------------------------------------------------
    | Supabase Services
    |--------------------------------------------------------------------------
    |
    | Configure which Supabase services you want to enable.
    |
    */

    'services' => [
        'auth' => env('SUPABASE_ENABLE_AUTH', false),
        'database' => env('SUPABASE_ENABLE_DATABASE', false),
        'storage' => env('SUPABASE_ENABLE_STORAGE', true),
        'realtime' => env('SUPABASE_ENABLE_REALTIME', false),
    ],

    'storage' => [
        'bucket' => env('SUPABASE_STORAGE_BUCKET', 'uploads'),
        'signed_url_ttl' => (int) env('SUPABASE_STORAGE_SIGNED_URL_TTL', 3600),
    ],

    'jwt' => [
        'issuer' => env('SUPABASE_JWT_ISSUER', rtrim((string) env('SUPABASE_URL', ''), '/').'/auth/v1'),
        'jwks_url' => env('SUPABASE_JWKS_URL', rtrim((string) env('SUPABASE_URL', ''), '/').'/auth/v1/.well-known/jwks.json'),
        'cache_ttl' => (int) env('SUPABASE_JWKS_CACHE_TTL', 3600),
        'leeway' => (int) env('SUPABASE_JWT_LEEWAY', 60),
        'allowed_audiences' => array_values(array_filter(array_map(
            static fn (string $audience): string => trim($audience),
            explode(',', (string) env('SUPABASE_ALLOWED_AUDIENCES', 'authenticated')),
        ))),
    ],

    /*
    |--------------------------------------------------------------------------
    | HTTP Client Configuration
    |--------------------------------------------------------------------------
    |
    | Configure the HTTP client settings for Supabase requests.
    |
    */

    'http' => [
        'timeout' => 30,
        'retries' => 3,
    ],
];