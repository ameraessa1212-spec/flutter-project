<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class EligibleStudentSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('eligible_students')->insertOrIgnore([
            ['student_number' => '1212', 'name' => 'Student One'],
            ['student_number' => '2323', 'name' => 'Student Two'],
            ['student_number' => '3434', 'name' => 'Student Three'],
            ['student_number' => '5656', 'name' => 'Student Four'],
            ['student_number' => '7878', 'name' => 'Student Five'],
        ]);
    }
}
