<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminRoleMiddleware
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json(['message' => 'غير مصرح.'], 401);
        }

        if (! empty($roles) && ! in_array($user->role, $roles)) {
            return response()->json([
                'message' => 'ليس لديك صلاحية الوصول.',
            ], 403);
        }

        return $next($request);
    }
}
