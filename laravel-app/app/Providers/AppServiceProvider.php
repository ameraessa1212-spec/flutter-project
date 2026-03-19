<?php

namespace App\Providers;

use App\Models\Application;
use App\Models\ChatThread;
use App\Models\Internship;
use App\Models\Report;
use App\Models\UserNotification;
use App\Models\UserSetting;
use App\Policies\ApplicationPolicy;
use App\Policies\ChatThreadPolicy;
use App\Policies\InternshipPolicy;
use App\Policies\ReportPolicy;
use App\Policies\UserNotificationPolicy;
use App\Policies\UserSettingPolicy;
use Illuminate\Support\Facades\Gate;
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
        Gate::policy(Application::class, ApplicationPolicy::class);
        Gate::policy(Internship::class, InternshipPolicy::class);
        Gate::policy(Report::class, ReportPolicy::class);
        Gate::policy(ChatThread::class, ChatThreadPolicy::class);
        Gate::policy(UserNotification::class, UserNotificationPolicy::class);
        Gate::policy(UserSetting::class, UserSettingPolicy::class);
    }
}
