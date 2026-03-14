<?php

namespace App\Providers;

use App\Services\Supabase\SupabaseUserResolver;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Auth::viaRequest('supabase', function (Request $request) {
            return app(SupabaseUserResolver::class)->resolve($request);
        });
    }
}
