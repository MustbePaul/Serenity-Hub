<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\MoodCheckin;
use App\Models\User;
use App\Models\WellnessSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class MultimediaFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_it_lists_published_media(): void
    {
        MediaAsset::create([
            'title' => 'Calm Audio',
            'media_type' => 'audio',
            'file_url' => 'https://example.com/audio.mp3',
            'status' => 'published',
        ]);
        MediaAsset::create([
            'title' => 'Draft Audio',
            'media_type' => 'audio',
            'file_url' => 'https://example.com/draft.mp3',
            'status' => 'draft',
        ]);

        $this->getJson('/api/v1/media?type=audio')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Calm Audio');
    }

    public function test_it_lists_wellness_sessions(): void
    {
        $media = MediaAsset::create([
            'title' => 'Breathing Audio',
            'media_type' => 'audio',
            'file_url' => 'https://example.com/breathe.mp3',
            'status' => 'published',
        ]);
        WellnessSession::create([
            'title' => 'Breathing Reset',
            'category' => 'breathing',
            'media_asset_id' => $media->id,
            'is_featured' => true,
            'status' => 'published',
        ]);

        $this->getJson('/api/v1/wellness-sessions?featured=1')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.media_asset.title', 'Breathing Audio');
    }

    public function test_authenticated_user_can_save_media_progress(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);
        $media = MediaAsset::create([
            'title' => 'Sleep Audio',
            'media_type' => 'audio',
            'file_url' => 'https://example.com/sleep.mp3',
            'status' => 'published',
        ]);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson("/api/v1/media/{$media->id}/progress", [
                'progress_seconds' => 96,
                'duration_seconds' => 100,
            ])
            ->assertCreated()
            ->assertJsonPath('data.progress_percent', 96)
            ->assertJsonPath('data.is_completed', true);

        $this->assertDatabaseHas('user_media_progress', [
            'user_id' => $user->id,
            'media_asset_id' => $media->id,
            'is_completed' => true,
        ]);
    }

    public function test_recommendations_use_latest_mood(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);
        $media = MediaAsset::create([
            'title' => 'Grounding Audio',
            'media_type' => 'audio',
            'file_url' => 'https://example.com/grounding.mp3',
            'status' => 'published',
        ]);
        WellnessSession::create([
            'title' => 'Grounding Practice',
            'category' => 'grounding',
            'target_mood' => 'anxious',
            'media_asset_id' => $media->id,
            'status' => 'published',
        ]);
        MoodCheckin::create([
            'user_id' => $user->id,
            'mood_score' => 2,
            'tags' => ['anxious'],
            'checked_in_at' => now(),
        ]);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->getJson('/api/v1/me/recommendations')
            ->assertOk()
            ->assertJsonPath('data.mood_key', 'anxious')
            ->assertJsonPath('data.sessions.0.title', 'Grounding Practice');
    }
}
