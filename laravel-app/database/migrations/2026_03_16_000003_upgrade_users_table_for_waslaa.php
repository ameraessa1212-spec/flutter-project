<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->uuid('supabase_user_id')->nullable()->change();
            $table->string('first_name')->nullable();
            $table->string('last_name')->nullable();
            $table->string('username')->nullable()->unique();
            $table->string('phone')->nullable()->unique();
            $table->string('password')->nullable();
            $table->string('role', 32)->default('student')->index();
            $table->string('status', 32)->default('pending')->index();
            $table->timestampTz('phone_verified_at')->nullable();
            $table->timestampTz('last_login_at')->nullable();
            $table->rememberToken();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'first_name',
                'last_name',
                'username',
                'phone',
                'password',
                'role',
                'status',
                'phone_verified_at',
                'last_login_at',
                'remember_token',
            ]);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->uuid('supabase_user_id')->nullable(false)->change();
        });
    }
};
