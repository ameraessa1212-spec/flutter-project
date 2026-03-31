<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PublicMediaControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_media_responses_include_cors_headers(): void
    {
        Storage::fake('public');
        Storage::disk('public')->put('avatars/test-image.txt', 'cors-ok');

        $response = $this->withHeaders([
            'Origin' => 'http://localhost:30874',
        ])->get('/media/public/avatars/test-image.txt');

        $response
            ->assertOk()
            ->assertHeader('Access-Control-Allow-Origin', '*')
            ->assertHeader('Access-Control-Allow-Methods', 'GET, OPTIONS')
            ->assertHeader('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization, Range')
            ->assertHeader('Access-Control-Expose-Headers', 'Content-Length, Content-Range, Content-Type')
            ->assertHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    }

    public function test_public_media_options_requests_include_cors_headers(): void
    {
        $response = $this->withHeaders([
            'Origin' => 'http://localhost:30874',
            'Access-Control-Request-Method' => 'GET',
        ])->call('OPTIONS', '/media/public/avatars/test-image.txt');

        $response
            ->assertNoContent()
            ->assertHeader('Access-Control-Allow-Origin', '*')
            ->assertHeader('Access-Control-Allow-Methods', 'GET, OPTIONS')
            ->assertHeader('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization, Range')
            ->assertHeader('Access-Control-Expose-Headers', 'Content-Length, Content-Range, Content-Type')
            ->assertHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    }
}