<?php

namespace App\Services\Supabase;

use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use InvalidArgumentException;
use UnexpectedValueException;

class SupabaseUserResolver
{
    public function __construct(private readonly SupabaseJwtVerifier $jwtVerifier) {}

    public function resolve(Request $request): ?User
    {
        $token = $request->bearerToken();

        if (! $token) {
            return null;
        }

        try {
            $claims = $this->jwtVerifier->verify($token);
        } catch (InvalidArgumentException|UnexpectedValueException) {
            return null;
        }

        $request->attributes->set('supabase.claims', $claims);

        return User::query()->updateOrCreate(
            ['supabase_user_id' => Arr::get($claims, 'sub')],
            $this->attributesFromClaims($claims),
        );
    }

    protected function attributesFromClaims(array $claims): array
    {
        $metadata = Arr::get($claims, 'user_metadata', []);

        if (! is_array($metadata)) {
            $metadata = [];
        }

        return [
            'email' => Arr::get($claims, 'email'),
            'name' => Arr::get($metadata, 'full_name')
                ?? Arr::get($metadata, 'name')
                ?? Arr::get($claims, 'email')
                ?? 'Supabase User',
            'email_verified_at' => $this->parseDate(Arr::get($claims, 'email_confirmed_at')),
            'last_sign_in_at' => $this->parseDate(Arr::get($claims, 'iat')),
            'user_metadata' => $metadata === [] ? null : $metadata,
        ];
    }

    protected function parseDate(mixed $value): ?CarbonImmutable
    {
        if (blank($value)) {
            return null;
        }

        try {
            if (is_numeric($value)) {
                return CarbonImmutable::createFromTimestampUTC((int) $value);
            }

            return CarbonImmutable::parse((string) $value);
        } catch (\Throwable) {
            return null;
        }
    }
}