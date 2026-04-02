<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class SpecializationsSeeder extends Seeder
{
    public function run(): void
    {
        $now = Carbon::now();

        DB::table('specializations')->insert([
            ['name' => 'حاسب الي', 'code' => 'CS', 'is_active' => 1, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'تحكم', 'code' => 'IT', 'is_active' => 1, 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'اتصالات', 'code' => 'SE', 'is_active' => 1, 'created_at' => $now, 'updated_at' => $now],
        ]);
    }
}