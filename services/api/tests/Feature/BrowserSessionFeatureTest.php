<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BrowserSessionFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_browser_session_can_read_and_requires_csrf_for_api_writes(): void
    {
        $user = User::factory()->create(['status' => 'active']);

        $this->actingAs($user, 'web')->withSession(['_token' => 'test-csrf-value'])
            ->getJson('/api/v1/auth/me')->assertOk();

        $this->postJson('/api/v1/mood-checkins', ['mood_score' => 3])->assertStatus(419);

        $this->withHeader('X-CSRF-TOKEN', 'test-csrf-value')
            ->postJson('/api/v1/mood-checkins', ['mood_score' => 3])->assertCreated();

        $this->assertDatabaseHas('mood_checkins', ['user_id' => $user->id, 'mood_score' => 3]);
    }

    public function test_browser_registration_does_not_create_a_mobile_bearer_token(): void
    {
        $response = $this->postJson('/web/register', [
            'name' => 'Browser Tester',
            'email' => 'browser@example.test',
            'password' => 'long-test-password',
            'privacy_consent' => true,
        ])->assertCreated();

        $response->assertJsonMissingPath('token');
        $this->assertNull(User::where('email', 'browser@example.test')->firstOrFail()->api_token);
    }

    public function test_browser_login_reuses_the_authoritative_api_without_returning_a_token(): void
    {
        $user = User::factory()->create(['status' => 'active', 'password' => 'test-password']);
        $response = $this->postJson('/web/login', ['email' => $user->email, 'password' => 'test-password'])
            ->assertOk();
        $response->assertJsonMissingPath('token');
        $this->getJson('/api/v1/auth/me')->assertOk()->assertJsonPath('data.id', $user->id);
    }
}
