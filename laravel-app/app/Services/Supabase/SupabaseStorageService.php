<?php

namespace App\Services\Supabase;

use Illuminate\Http\UploadedFile;
use RuntimeException;
use Saeedvir\Supabase\Facades\Supabase;

class SupabaseStorageService
{
    public function upload(UploadedFile $file, ?string $path = null, ?string $bucket = null, bool $isPublic = false): array
    {
        $bucket ??= (string) config('supabase.storage.bucket');

        if ($bucket === '') {
            throw new RuntimeException('Set SUPABASE_STORAGE_BUCKET before uploading files.');
        }

        $path = $this->normalizePath($path ?: $file->hashName());

        $response = Supabase::storage()->upload($bucket, $path, $file->getRealPath(), [
            'cacheControl' => '3600',
            'upsert' => true,
        ]);

        return [
            'bucket' => $bucket,
            'path' => $path,
            'visibility' => $isPublic ? 'public' : 'private',
            'url' => $isPublic
                ? Supabase::storage()->publicUrl($bucket, $path)
                : $this->signedUrl($bucket, $path),
            'response' => $response,
        ];
    }

    public function signedUrl(string $bucket, string $path, ?int $expiresIn = null): ?string
    {
        $result = Supabase::storage()->createSignedUrl(
            $bucket,
            $path,
            $expiresIn ?? (int) config('supabase.storage.signed_url_ttl', 3600),
        );

        $signedUrl = $result['signedURL'] ?? $result['signedUrl'] ?? null;

        if (! is_string($signedUrl) || $signedUrl === '') {
            return null;
        }

        if (str_starts_with($signedUrl, 'http://') || str_starts_with($signedUrl, 'https://')) {
            return $signedUrl;
        }

        return rtrim((string) config('supabase.url'), '/').$signedUrl;
    }

    protected function normalizePath(string $path): string
    {
        return trim($path, '/');
    }
}