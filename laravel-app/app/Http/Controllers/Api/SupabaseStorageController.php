<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Supabase\SupabaseStorageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class SupabaseStorageController extends Controller
{
    public function __construct(private readonly SupabaseStorageService $storageService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'file' => ['required', 'file', 'max:10240'],
            'path' => ['nullable', 'string', 'max:255'],
            'bucket' => ['nullable', 'string', 'max:255'],
            'visibility' => ['nullable', 'in:private,public'],
        ]);

        try {
            $uploaded = $this->storageService->upload(
                $request->file('file'),
                $validated['path'] ?? null,
                $validated['bucket'] ?? null,
                ($validated['visibility'] ?? 'private') === 'public',
            );
        } catch (RuntimeException $exception) {
            return response()->json([
                'message' => $exception->getMessage(),
            ], 422);
        }

        return response()->json($uploaded, 201);
    }
}