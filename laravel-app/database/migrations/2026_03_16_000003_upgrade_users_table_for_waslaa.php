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
        $hasFirstName = Schema::hasColumn('users', 'first_name');
        $hasLastName = Schema::hasColumn('users', 'last_name');
        $hasUsername = Schema::hasColumn('users', 'username');
        $hasPhone = Schema::hasColumn('users', 'phone');
        $hasPassword = Schema::hasColumn('users', 'password');
        $hasRole = Schema::hasColumn('users', 'role');
        $hasStatus = Schema::hasColumn('users', 'status');
        $hasPhoneVerifiedAt = Schema::hasColumn('users', 'phone_verified_at');
        $hasLastLoginAt = Schema::hasColumn('users', 'last_login_at');
        $hasRememberToken = Schema::hasColumn('users', 'remember_token');

        if (
            $hasFirstName
            && $hasLastName
            && $hasUsername
            && $hasPhone
            && $hasPassword
            && $hasRole
            && $hasStatus
            && $hasPhoneVerifiedAt
            && $hasLastLoginAt
            && $hasRememberToken
        ) {
            return;
        }

        Schema::table('users', function (Blueprint $table) use (
            $hasFirstName,
            $hasLastName,
            $hasUsername,
            $hasPhone,
            $hasPassword,
            $hasRole,
            $hasStatus,
            $hasPhoneVerifiedAt,
            $hasLastLoginAt,
            $hasRememberToken,
        ) {
            if (! $hasFirstName) {
                $table->string('first_name')->nullable();
            }

            if (! $hasLastName) {
                $table->string('last_name')->nullable();
            }

            if (! $hasUsername) {
                $table->string('username')->nullable()->unique();
            }

            if (! $hasPhone) {
                $table->string('phone')->nullable()->unique();
            }

            if (! $hasPassword) {
                $table->string('password')->nullable();
            }

            if (! $hasRole) {
                $table->string('role', 32)->default('student')->index();
            }

            if (! $hasStatus) {
                $table->string('status', 32)->default('pending')->index();
            }

            if (! $hasPhoneVerifiedAt) {
                $table->timestampTz('phone_verified_at')->nullable();
            }

            if (! $hasLastLoginAt) {
                $table->timestampTz('last_login_at')->nullable();
            }

            if (! $hasRememberToken) {
                $table->rememberToken();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $dropColumns = array_values(array_filter([
            Schema::hasColumn('users', 'first_name') ? 'first_name' : null,
            Schema::hasColumn('users', 'last_name') ? 'last_name' : null,
            Schema::hasColumn('users', 'username') ? 'username' : null,
            Schema::hasColumn('users', 'phone') ? 'phone' : null,
            Schema::hasColumn('users', 'password') ? 'password' : null,
            Schema::hasColumn('users', 'role') ? 'role' : null,
            Schema::hasColumn('users', 'status') ? 'status' : null,
            Schema::hasColumn('users', 'phone_verified_at') ? 'phone_verified_at' : null,
            Schema::hasColumn('users', 'last_login_at') ? 'last_login_at' : null,
            Schema::hasColumn('users', 'remember_token') ? 'remember_token' : null,
        ]));

        if (count($dropColumns) > 0) {
            Schema::table('users', function (Blueprint $table) use ($dropColumns) {
                $table->dropColumn($dropColumns);
            });
        }

    }
};
