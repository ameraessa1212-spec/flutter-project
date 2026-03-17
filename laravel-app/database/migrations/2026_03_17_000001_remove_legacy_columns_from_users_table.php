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
        if (! Schema::hasTable('users')) {
            return;
        }

        $dropColumns = array_values(array_filter([
            Schema::hasColumn('users', 'supabase_user_id') ? 'supabase_user_id' : null,
            Schema::hasColumn('users', 'user_metadata') ? 'user_metadata' : null,
            Schema::hasColumn('users', 'last_sign_in_at') ? 'last_sign_in_at' : null,
        ]));

        if (count($dropColumns) === 0) {
            return;
        }

        Schema::table('users', function (Blueprint $table) use ($dropColumns) {
            $table->dropColumn($dropColumns);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Intentionally left blank. These columns are legacy and should not be restored.
    }
};
