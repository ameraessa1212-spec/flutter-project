<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class EligibleStudentSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('eligible_students')->insertOrIgnore([
            ['student_number' => '192074', 'name' => 'Student One'],
        ]);
    }
}
