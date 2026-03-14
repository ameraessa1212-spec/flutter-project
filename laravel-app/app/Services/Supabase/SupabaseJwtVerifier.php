<?php

namespace App\Services\Supabase;

use Firebase\JWT\JWK;
use Firebase\JWT\JWT;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use InvalidArgumentException;
use RuntimeException;
use UnexpectedValueException;

class SupabaseJwtVerifier
{
    public function verify(string $token): array
    {
        if (blank($token)) {
            throw new InvalidArgumentException('Supabase access token is required.');
        }

        JWT::$leeway = (int) config('supabase.jwt.leeway', 60);

        $decoded = JWT::decode($token, JWK::parseKeySet($this->jwks()));
        $claims = json_decode(json_encode($decoded, JSON_THROW_ON_ERROR), true, 512, JSON_THROW_ON_ERROR);

        $this->assertIssuer($claims);
        $this->assertAudience($claims);

        if (! filled(Arr::get($claims, 'sub'))) {
            throw new UnexpectedValueException('Supabase token is missing the subject claim.');
        }

        return $claims;
    }

    protected function jwks(): array
    {
        $jwksUrl = (string) config('supabase.jwt.jwks_url');

        if ($jwksUrl === '') {
            throw new RuntimeException('Set SUPABASE_JWKS_URL or SUPABASE_URL before using Supabase authentication.');
        }

        $cacheKey = 'supabase:jwks:'.md5($jwksUrl);
        $ttl = max((int) config('supabase.jwt.cache_ttl', 3600), 60);

        return Cache::remember($cacheKey, now()->addSeconds($ttl), function () use ($jwksUrl) {
            $response = Http::acceptJson()
                ->timeout((int) config('supabase.http.timeout', 30))
                ->retry((int) config('supabase.http.retries', 3), 200)
                ->get($jwksUrl)
                ->throw()
                ->json();

            if (! is_array($response) || ! isset($response['keys']) || ! is_array($response['keys'])) {
                throw new RuntimeException('Supabase JWKS response is invalid.');
            }

            return $response;
        });
    }

    protected function assertIssuer(array $claims): void
    {
        $expectedIssuer = rtrim((string) config('supabase.jwt.issuer', ''), '/');

        if ($expectedIssuer === '') {
            return;
        }

        $actualIssuer = rtrim((string) Arr::get($claims, 'iss', ''), '/');

        if ($actualIssuer !== $expectedIssuer) {
            throw new UnexpectedValueException('Supabase token issuer is invalid.');
        }
    }

    protected function assertAudience(array $claims): void
    {
        $allowedAudiences = array_filter(config('supabase.jwt.allowed_audiences', []));

        if ($allowedAudiences === []) {
            return;
        }

        $tokenAudiences = Arr::wrap(Arr::get($claims, 'aud', []));

        if (array_intersect($allowedAudiences, $tokenAudiences) === []) {
            throw new UnexpectedValueException('Supabase token audience is invalid.');
        }
    }
}