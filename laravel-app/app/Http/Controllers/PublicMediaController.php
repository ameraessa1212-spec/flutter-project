<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class PublicMediaController extends Controller
{
    public function show(string $path): BinaryFileResponse
    {
        abort_if(str_contains($path, '..'), Response::HTTP_NOT_FOUND);
        abort_unless(Storage::disk('public')->exists($path), Response::HTTP_NOT_FOUND);

        return response()->file(
            Storage::disk('public')->path($path),
            $this->corsHeaders(),
        );
    }

    public function options(Request $request): Response
    {
        return response()->noContent(headers: $this->corsHeaders());
    }

    private function corsHeaders(): array
    {
        return [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept, Authorization, Range',
            'Access-Control-Expose-Headers' => 'Content-Length, Content-Range, Content-Type',
            'Cross-Origin-Resource-Policy' => 'cross-origin',
        ];
    }
}