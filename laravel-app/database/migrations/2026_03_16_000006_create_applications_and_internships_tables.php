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
        Schema::create('applications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('opportunity_id')->constrained('internship_opportunities')->cascadeOnDelete();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->string('full_name_snapshot');
            $table->string('phone_snapshot')->nullable();
            $table->string('email_snapshot')->nullable();
            $table->string('university_snapshot')->nullable();
            $table->string('major_snapshot')->nullable();
            $table->string('level_snapshot')->nullable();
            $table->string('cv_file_path')->nullable();
            $table->text('notes')->nullable();
            $table->string('status', 32)->default('pending')->index();
            $table->timestampTz('submitted_at')->nullable();
            $table->timestampTz('reviewed_at')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('review_notes')->nullable();
            $table->timestampsTz();

            $table->unique(['student_id', 'opportunity_id']);
            $table->index(['company_id', 'status']);
        });

        Schema::create('internships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('application_id')->unique()->constrained('applications')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->foreignId('opportunity_id')->nullable()->constrained('internship_opportunities')->nullOnDelete();
            $table->foreignId('supervisor_id')->nullable()->constrained('supervisors')->nullOnDelete();
            $table->string('title');
            $table->string('status', 32)->default('active')->index();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->date('report_due_date')->nullable();
            $table->text('notes')->nullable();
            $table->timestampsTz();

            $table->index(['student_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('internships');
        Schema::dropIfExists('applications');
    }
};
