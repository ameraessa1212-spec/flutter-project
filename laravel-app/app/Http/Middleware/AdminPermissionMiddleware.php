<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminPermissionMiddleware
{
    public function handle(Request $request, Closure $next, string ...$permissions): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json(['message' => 'غير مصرح.'], 401);
        }

        foreach ($permissions as $permission) {
            if (! $user->hasPermissionTo($permission)) {
                return response()->json([
                    'message' => 'ليس لديك الصلاحية المطلوبة.',
                    'required' => $permission,
                ], 403);
            }
        }

        return $next($request);
    }
}
