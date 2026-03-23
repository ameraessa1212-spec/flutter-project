<?php

namespace Tests\Feature\Api\Mobile;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class InternshipCurrentTest extends TestCase
{
    use RefreshDatabase;

    public function test_current_endpoint_returns_null_when_student_has_no_active_internship(): void
    {
        $student = User::factory()->create([
            'role' => 'student',
            'status' => 'active',
        ]);

        Sanctum::actingAs($student);

        $response = $this->getJson('/api/mobile/v1/internships/current');

        $response
            ->assertOk()
            ->assertExactJson([
                'data' => null,
            ]);
    }
}