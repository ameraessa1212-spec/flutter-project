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
        Schema::table('company_evaluations', function (Blueprint $table) {
            $table->dropColumn(['performance_score', 'attendance_score', 'initiative_score', 'teamwork_score']);
            $table->json('detailed_scores')->nullable();
            $table->integer('total_score')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('company_evaluations', function (Blueprint $table) {
            $table->dropColumn(['detailed_scores', 'total_score']);
            $table->integer('performance_score')->default(0);
            $table->integer('attendance_score')->default(0);
            $table->integer('initiative_score')->default(0);
            $table->integer('teamwork_score')->default(0);
        });
    }
};
