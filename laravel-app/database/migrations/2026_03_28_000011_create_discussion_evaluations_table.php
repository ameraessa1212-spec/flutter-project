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
        Schema::create('discussion_evaluations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('examiner_discussion_id')
                ->constrained('examiner_discussions')
                ->cascadeOnDelete();
            $table->foreignId('internship_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('examiner_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('total_score', 6, 2)->nullable();
            $table->string('decision', 32)->default('pending')->index();
            $table->json('rubric_scores')->nullable();
            $table->text('notes')->nullable();
            $table->boolean('visible_to_supervisor')->default(true);
            $table->boolean('visible_to_company')->default(true);
            $table->boolean('visible_to_student')->default(false);
            $table->timestampTz('submitted_at')->nullable();
            $table->timestampsTz();

            $table->unique('examiner_discussion_id');
            $table->index(['examiner_id', 'decision']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('discussion_evaluations');
    }
};
