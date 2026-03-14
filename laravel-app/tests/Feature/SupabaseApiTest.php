<?php

namespace Tests\Feature;

use Tests\TestCase;

class SupabaseApiTest extends TestCase
{
    public function test_supabase_health_endpoint_returns_configuration_summary(): void
    {
        $response = $this->getJson('/api/supabase/health');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'supabase_url_configured',
                'storage_bucket',
                'db_connection',
                'db_schema',
            ]);
    }

    public function test_current_user_endpoint_requires_supabase_authentication(): void
    {
        $this->getJson('/api/me')->assertUnauthorized();
    }
}