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
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('internship_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('report_type', 32)->index();
            $table->string('title');
            $table->string('file_path');
            $table->string('file_name');
            $table->string('file_extension', 16)->nullable();
            $table->unsignedBigInteger('file_size')->nullable();
            $table->string('status', 32)->default('submitted')->index();
            $table->timestampTz('submitted_at')->nullable();
            $table->timestampTz('reviewed_at')->nullable();
            $table->text('review_notes')->nullable();
            $table->timestampsTz();

            $table->unique(['internship_id', 'report_type']);
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('body');
            $table->string('type', 32)->default('system')->index();
            $table->nullableMorphs('reference');
            $table->boolean('is_read')->default(false)->index();
            $table->timestampTz('read_at')->nullable();
            $table->timestampsTz();
        });

        Schema::create('discussion_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('specialization_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('academic_term')->nullable()->index();
            $table->string('schedule_file_path')->nullable();
            $table->string('schedule_image_path')->nullable();
            $table->timestampTz('published_at')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestampsTz();
        });

        Schema::create('user_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('language', 10)->default('ar');
            $table->boolean('push_notifications_enabled')->default(true);
            $table->boolean('email_notifications_enabled')->default(true);
            $table->boolean('chat_notifications_enabled')->default(true);
            $table->string('theme', 20)->default('light');
            $table->timestampsTz();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_settings');
        Schema::dropIfExists('discussion_schedules');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('reports');
    }
};
