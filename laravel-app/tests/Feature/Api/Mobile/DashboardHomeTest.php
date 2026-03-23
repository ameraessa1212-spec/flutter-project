<?php

namespace Tests\Feature\Api\Mobile;

use App\Models\DashboardContent;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DashboardHomeTest extends TestCase
{
    use RefreshDatabase;

    public function test_home_dashboard_returns_expected_empty_state_payload(): void
    {
        $student = User::factory()->create([
            'role' => 'student',
            'status' => 'active',
        ]);

        Sanctum::actingAs($student);

        $response = $this->getJson('/api/mobile/v1/dashboard/home');

        $response
            ->assertOk()
            ->assertJson([
                'data' => [
                    'applications_count' => 0,
                    'unread_notifications_count' => 0,
                    'current_internship' => null,
                    'featured_opportunities' => [],
                    'slider_items' => [],
                    'tip_cards' => [],
                    'announcements' => [],
                ],
            ]);
    }

    public function test_home_dashboard_returns_managed_content_items(): void
    {
        $student = User::factory()->create([
            'role' => 'student',
            'status' => 'active',
        ]);

        DashboardContent::query()->create([
            'type' => 'slider',
            'title' => 'عنوان سلايدر',
            'subtitle' => 'وصف السلايدر',
            'image_asset' => 'assets/images/madar.JPG',
            'sort_order' => 1,
            'is_active' => true,
        ]);

        DashboardContent::query()->create([
            'type' => 'tip',
            'title' => 'نصيحة',
            'subtitle' => 'راجع سيرتك الذاتية قبل التقديم.',
            'icon_key' => 'article',
            'sort_order' => 1,
            'is_active' => true,
        ]);

        DashboardContent::query()->create([
            'type' => 'announcement',
            'title' => 'إعلان',
            'subtitle' => 'تم فتح دفعة جديدة من فرص التدريب.',
            'badge' => 'جديد',
            'icon_key' => 'campaign',
            'sort_order' => 1,
            'is_active' => true,
        ]);

        Sanctum::actingAs($student);

        $response = $this->getJson('/api/mobile/v1/dashboard/home');

        $response
            ->assertOk()
            ->assertJsonPath('data.slider_items.0.title', 'عنوان سلايدر')
            ->assertJsonPath('data.tip_cards.0.title', 'نصيحة')
            ->assertJsonPath('data.announcements.0.title', 'إعلان');
    }
}