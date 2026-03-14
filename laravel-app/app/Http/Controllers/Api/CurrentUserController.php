<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;

class CurrentUserController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $claims = (array) $request->attributes->get('supabase.claims', []);

        return response()->json([
            'user' => $request->user(),
            'supabase' => [
                'sub' => Arr::get($claims, 'sub'),
                'email' => Arr::get($claims, 'email'),
                'role' => Arr::get($claims, 'role'),
                'aud' => Arr::get($claims, 'aud'),
            ],
        ]);
    }
}