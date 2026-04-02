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
        Schema::create('examiner_discussions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('internship_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('examiner_id')->constrained('users')->cascadeOnDelete();
            $table->timestampTz('scheduled_at')->nullable()->index();
            $table->string('location')->nullable();
            $table->string('meeting_link')->nullable();
            $table->string('status', 32)->default('scheduled')->index();
            $table->boolean('is_urgent')->default(false)->index();
            $table->text('notes')->nullable();
            $table->timestampsTz();

            $table->index(['examiner_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('examiner_discussions');
    }
};
