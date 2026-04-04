<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('chat_threads', function (Blueprint $table) {
            $table->foreignId('internship_id')->nullable()->change();
            $table->foreignId('supervisor_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('chat_threads', function (Blueprint $table) {
            $table->foreignId('internship_id')->nullable(false)->change();
            $table->foreignId('supervisor_id')->nullable(false)->change();
        });
    }
};
