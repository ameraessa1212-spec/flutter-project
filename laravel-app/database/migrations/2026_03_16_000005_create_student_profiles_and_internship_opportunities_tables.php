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
        Schema::create('student_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('specialization_id')->nullable()->constrained()->nullOnDelete();
            $table->string('university_name')->nullable();
            $table->string('student_number')->nullable()->unique();
            $table->string('study_level')->nullable();
            $table->text('bio')->nullable();
            $table->string('profile_image_path')->nullable();
            $table->string('cv_file_path')->nullable();
            $table->date('expected_graduation_at')->nullable();
            $table->timestampsTz();
        });

        Schema::create('internship_opportunities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('specialization_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->text('description');
            $table->string('city')->nullable()->index();
            $table->string('location_text')->nullable();
            $table->string('duration_text')->nullable();
            $table->unsignedSmallInteger('duration_days')->nullable();
            $table->unsignedInteger('seats_count')->nullable();
            $table->boolean('is_available')->default(true)->index();
            $table->string('status', 32)->default('draft')->index();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->date('application_deadline')->nullable();
            $table->string('image_path')->nullable();
            $table->timestampsTz();

            $table->index(['company_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('internship_opportunities');
        Schema::dropIfExists('student_profiles');
    }
};
