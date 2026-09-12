<?php

namespace Tests\Feature;

use App\Models\CommunityIdentity;
use App\Models\CommunityMessage;
use App\Models\CommunityModerationAudit;
use App\Models\CommunityPostingRestriction;
use App\Models\CommunityRoom;
use App\Models\User;
use App\Events\CommunityMessageCreated;
use App\Events\CommunityMessageRemoved;
use App\Events\CommunityReactionUpdated;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Tests\TestCase;

class CommunityFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_users_cannot_post(): void
    {
        $room = $this->room();

        $this->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'Hello'])
            ->assertUnauthorized();
    }

    public function test_authenticated_users_receive_stable_anonymous_identity(): void
    {
        $user = $this->user();

        $first = $this->actingWithToken($user)->getJson('/api/v1/community/me')
            ->assertOk()
            ->assertJsonStructure(['data' => ['id', 'display_name', 'avatar_seed']])
            ->assertJsonMissing(['user_id' => $user->id])
            ->json('data');

        $second = $this->actingWithToken($user)->getJson('/api/v1/community/me')
            ->assertOk()
            ->json('data');

        $this->assertSame($first['id'], $second['id']);
        $this->assertDatabaseHas('community_identities', ['user_id' => $user->id, 'anonymous_code' => $first['id']]);
    }

    public function test_posting_a_message_works(): void
    {
        $user = $this->user(['name' => 'Private Name', 'email' => 'private@example.test']);
        $room = $this->room();

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => '   I am having a difficult day today.   '])
            ->assertCreated()
            ->assertJsonPath('data.message.body', 'I am having a difficult day today.')
            ->assertJsonPath('data.message.is_mine', true)
            ->assertJsonMissing(['email' => 'private@example.test'])
            ->assertJsonMissing(['name' => 'Private Name'])
            ->assertJsonMissing(['user_id' => $user->id]);

        $this->assertDatabaseHas('community_messages', [
            'room_id' => $room->id,
            'body' => 'I am having a difficult day today.',
            'status' => CommunityMessage::STATUS_PUBLISHED,
        ]);
    }

    public function test_replies_work_and_only_one_reply_level_is_allowed(): void
    {
        $user = $this->user();
        $room = $this->room();
        $message = $this->message($room, $this->identity($user));

        $replyId = $this->actingWithToken($user)
            ->postJson("/api/v1/community/messages/{$message->id}/replies", ['body' => 'I relate to this.'])
            ->assertCreated()
            ->assertJsonPath('data.message.body', 'I relate to this.')
            ->json('data.message.id');

        $this->actingWithToken($user)
            ->getJson("/api/v1/community/messages/{$message->id}/replies")
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $replyId);

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/messages/{$replyId}/replies", ['body' => 'Nested'])
            ->assertUnprocessable();
    }

    public function test_rooms_can_be_listed_from_database(): void
    {
        $user = $this->user();
        $this->room(['name' => 'World Room', 'slug' => 'world', 'sort_order' => 1]);
        $this->room(['name' => 'Hidden Room', 'slug' => 'hidden', 'is_active' => false, 'sort_order' => 2]);

        $this->actingWithToken($user)
            ->getJson('/api/v1/community/rooms')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'world');
    }

    public function test_pagination_works_for_messages(): void
    {
        $user = $this->user();
        $room = $this->room();
        $identity = $this->identity($user);

        for ($i = 1; $i <= 35; $i++) {
            $this->message($room, $identity, ['body' => "Message {$i}", 'created_at' => now()->addSeconds($i)]);
        }

        $this->actingWithToken($user)
            ->getJson("/api/v1/community/rooms/{$room->slug}/messages?per_page=30")
            ->assertOk()
            ->assertJsonCount(30, 'data')
            ->assertJsonPath('meta.total', 35)
            ->assertJsonPath('meta.last_page', 2)
            ->assertJsonPath('data.0.body', 'Message 35');
    }

    public function test_reactions_work_and_duplicates_are_deduplicated(): void
    {
        $user = $this->user();
        $other = $this->user();
        $room = $this->room();
        $message = $this->message($room, $this->identity($other));

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/messages/{$message->id}/reactions", ['reaction' => 'support'])
            ->assertOk()
            ->assertJsonPath('data.reactions.support', 1)
            ->assertJsonPath('data.my_reactions.0', 'support');

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/messages/{$message->id}/reactions", ['reaction' => 'support'])
            ->assertOk()
            ->assertJsonPath('data.reactions.support', 1);

        $this->assertDatabaseCount('community_reactions', 1);

        $this->actingWithToken($user)
            ->deleteJson("/api/v1/community/messages/{$message->id}/reactions/support")
            ->assertOk()
            ->assertJsonPath('data.reactions.support', 0);
    }

    public function test_reporting_works_without_exposing_reporter_account_data(): void
    {
        $reporter = $this->user(['email' => 'reporter@example.test']);
        $author = $this->user();
        $message = $this->message($this->room(), $this->identity($author));

        $this->actingWithToken($reporter)
            ->postJson("/api/v1/community/messages/{$message->id}/report", [
                'reason' => 'harassment',
                'details' => 'This felt targeted.',
            ])
            ->assertCreated()
            ->assertJsonPath('data.reason', 'harassment')
            ->assertJsonMissing(['email' => 'reporter@example.test'])
            ->assertJsonMissing(['user_id' => $reporter->id]);

        $this->assertDatabaseHas('community_reports', [
            'message_id' => $message->id,
            'reason' => 'harassment',
            'status' => 'pending',
        ]);
    }

    public function test_blocking_works_and_blocked_messages_are_filtered(): void
    {
        $viewer = $this->user();
        $author = $this->user();
        $room = $this->room();
        $viewerIdentity = $this->identity($viewer);
        $authorIdentity = $this->identity($author);
        $message = $this->message($room, $authorIdentity, ['body' => 'Please hide this from blocker']);

        $this->actingWithToken($viewer)
            ->postJson("/api/v1/community/identities/{$authorIdentity->anonymous_code}/block")
            ->assertOk();

        $this->assertDatabaseHas('community_blocks', [
            'blocker_community_identity_id' => $viewerIdentity->id,
            'blocked_community_identity_id' => $authorIdentity->id,
        ]);

        $this->actingWithToken($viewer)
            ->getJson("/api/v1/community/rooms/{$room->slug}/messages")
            ->assertOk()
            ->assertJsonMissing(['body' => $message->body]);

        $this->actingWithToken($viewer)
            ->deleteJson("/api/v1/community/identities/{$authorIdentity->anonymous_code}/block")
            ->assertOk();

        $this->actingWithToken($viewer)
            ->getJson("/api/v1/community/rooms/{$room->slug}/messages")
            ->assertOk()
            ->assertJsonPath('data.0.body', $message->body);
    }

    public function test_a_user_can_remove_their_own_message_but_not_another_users_message(): void
    {
        $owner = $this->user();
        $other = $this->user();
        $room = $this->room();
        $message = $this->message($room, $this->identity($owner));

        $this->actingWithToken($other)
            ->deleteJson("/api/v1/community/messages/{$message->id}")
            ->assertNotFound();

        $this->actingWithToken($owner)
            ->deleteJson("/api/v1/community/messages/{$message->id}")
            ->assertOk();

        $this->assertDatabaseHas('community_messages', [
            'id' => $message->id,
            'status' => CommunityMessage::STATUS_REMOVED,
        ]);
    }

    public function test_private_account_data_never_appears_in_public_message_json(): void
    {
        $author = $this->user(['name' => 'Very Real Name', 'email' => 'real@example.test']);
        $author->profile()->create(['phone' => '+265990000000']);
        $viewer = $this->user();
        $room = $this->room();
        $message = $this->message($room, $this->identity($author));

        $payload = $this->actingWithToken($viewer)
            ->getJson("/api/v1/community/rooms/{$room->slug}/messages")
            ->assertOk()
            ->assertJsonPath('data.0.id', $message->id)
            ->getContent();

        $this->assertStringNotContainsString('real@example.test', $payload);
        $this->assertStringNotContainsString('Very Real Name', $payload);
        $this->assertStringNotContainsString('+265990000000', $payload);
        $this->assertStringNotContainsString('user_id', $payload);
    }

    public function test_inactive_rooms_reject_posting(): void
    {
        $user = $this->user();
        $room = $this->room(['slug' => 'inactive', 'is_active' => false]);

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'Hello'])
            ->assertNotFound();
    }

    public function test_rate_limits_work_for_posting(): void
    {
        RateLimiter::clear('community-posts|rate-limit-user');

        $user = $this->user(['api_token' => 'rate-limit-user']);
        $room = $this->room();

        for ($i = 0; $i < 20; $i++) {
            $this->actingWithToken($user)
                ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => "Message {$i}"])
                ->assertCreated();
        }

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'Too many'])
            ->assertTooManyRequests();
    }

    public function test_invalid_reactions_are_rejected(): void
    {
        $user = $this->user();
        $message = $this->message($this->room(), $this->identity($this->user()));

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/messages/{$message->id}/reactions", ['reaction' => 'dislike'])
            ->assertUnprocessable();
    }

    public function test_safety_flags_behave_as_intended(): void
    {
        $user = $this->user();
        $room = $this->room();

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => "I'm struggling today."])
            ->assertCreated()
            ->assertJsonPath('data.safety.requires_review', false)
            ->assertJsonPath('data.message.status', CommunityMessage::STATUS_PUBLISHED);

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'My email is me@example.test'])
            ->assertCreated()
            ->assertJsonPath('data.safety.requires_review', true)
            ->assertJsonPath('data.safety.flags.0', 'personally_identifying_information')
            ->assertJsonPath('data.message.status', CommunityMessage::STATUS_UNDER_REVIEW);

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'I am 42 and breathing for 4 counts'])
            ->assertCreated()
            ->assertJsonPath('data.safety.requires_review', false);

        $this->actingWithToken($user)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'Text me on WhatsApp +265 999 000 000'])
            ->assertCreated()
            ->assertJsonPath('data.safety.flags.0', 'personally_identifying_information');
    }

    public function test_channel_authorization_allows_active_rooms_only_without_identity_leakage(): void
    {
        $user = $this->user();
        $room = $this->room(['slug' => 'world']);

        $content = $this->actingWithToken($user)
            ->postJson('/api/v1/community/broadcasting/auth', [
                'socket_id' => '123.456',
                'channel_name' => 'private-community.room.'.$room->slug,
            ])
            ->assertOk()
            ->assertJsonStructure(['auth'])
            ->getContent();

        $this->assertStringNotContainsString('user_id', $content);
        $this->assertStringNotContainsString($user->email, $content);

        $this->actingWithToken($user)
            ->postJson('/api/v1/community/broadcasting/auth', [
                'socket_id' => '123.456',
                'channel_name' => 'private-community.room.missing',
            ])
            ->assertForbidden();
    }

    public function test_message_events_are_dispatched_and_payloads_are_privacy_safe(): void
    {
        Event::fake([
            CommunityMessageCreated::class,
            CommunityReactionUpdated::class,
            CommunityMessageRemoved::class,
        ]);

        $author = $this->user(['email' => 'author@example.test', 'name' => 'Real Author']);
        $viewer = $this->user();
        $room = $this->room();

        $messageId = $this->actingWithToken($author)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'Hello safely'])
            ->assertCreated()
            ->json('data.message.id');

        Event::assertDispatched(CommunityMessageCreated::class, function ($event) use ($author) {
            $payload = json_encode($event->broadcastWith());

            return ! str_contains($payload, $author->email)
                && ! str_contains($payload, 'user_id')
                && ! str_contains($payload, 'moderation_notes')
                && isset($event->broadcastWith()['message']['anonymous_identity']['id']);
        });

        $this->actingWithToken($viewer)
            ->postJson("/api/v1/community/messages/{$messageId}/reactions", ['reaction' => 'support'])
            ->assertOk();

        Event::assertDispatched(CommunityReactionUpdated::class);

        $this->actingWithToken($author)
            ->deleteJson("/api/v1/community/messages/{$messageId}")
            ->assertOk();

        Event::assertDispatched(CommunityMessageRemoved::class);
    }

    public function test_moderator_report_queue_and_actions_are_protected_and_audited(): void
    {
        Event::fake([CommunityMessageRemoved::class]);

        $moderator = $this->user(['role' => 'moderator']);
        $ordinary = $this->user();
        $reporter = $this->user();
        $author = $this->user();
        $message = $this->message($this->room(), $this->identity($author));

        $this->actingWithToken($reporter)
            ->postJson("/api/v1/community/messages/{$message->id}/report", ['reason' => 'harassment'])
            ->assertCreated();

        $this->actingWithToken($ordinary)
            ->getJson('/api/v1/community/moderation/reports')
            ->assertForbidden();

        $reportId = $this->actingWithToken($moderator)
            ->getJson('/api/v1/community/moderation/reports')
            ->assertOk()
            ->assertJsonPath('data.0.reason', 'harassment')
            ->assertJsonMissing(['email' => $author->email])
            ->json('data.0.id');

        $this->actingWithToken($moderator)
            ->patchJson("/api/v1/community/moderation/reports/{$reportId}", ['status' => 'resolved'])
            ->assertOk()
            ->assertJsonPath('data.status', 'resolved');

        $this->actingWithToken($moderator)
            ->patchJson("/api/v1/community/moderation/messages/{$message->id}/hide", ['moderation_notes' => 'Internal note'])
            ->assertOk()
            ->assertJsonPath('data.message.status', CommunityMessage::STATUS_HIDDEN);

        Event::assertDispatched(CommunityMessageRemoved::class);
        $this->assertDatabaseHas(CommunityModerationAudit::class, ['action' => 'message_hidden']);
        $this->assertDatabaseHas(CommunityModerationAudit::class, ['action' => 'report_resolved']);
    }

    public function test_posting_restrictions_block_only_community_posts_and_can_expire(): void
    {
        $moderator = $this->user(['role' => 'admin']);
        $author = $this->user();
        $room = $this->room();
        $identity = $this->identity($author);

        $this->actingWithToken($moderator)
            ->postJson("/api/v1/community/moderation/identities/{$identity->anonymous_code}/restriction", [
                'state' => CommunityPostingRestriction::STATE_TEMPORARY,
                'reason' => 'Repeated spam',
                'expires_at' => now()->addHour()->toISOString(),
            ])
            ->assertCreated()
            ->assertJsonPath('data.state', CommunityPostingRestriction::STATE_TEMPORARY);

        $content = $this->actingWithToken($author)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'Can I post?'])
            ->assertForbidden()
            ->getContent();

        $this->assertStringContainsString("can't post", $content);

        CommunityPostingRestriction::query()->update(['expires_at' => now()->subMinute()]);

        $this->actingWithToken($author)
            ->postJson("/api/v1/community/rooms/{$room->slug}/messages", ['body' => 'I can post again'])
            ->assertCreated();
    }

    private function user(array $attributes = []): User
    {
        return User::factory()->create([
            'api_token' => $attributes['api_token'] ?? Str::random(40),
            'status' => 'active',
            ...$attributes,
        ]);
    }

    private function room(array $attributes = []): CommunityRoom
    {
        return CommunityRoom::create([
            'name' => $attributes['name'] ?? 'World Room',
            'slug' => $attributes['slug'] ?? 'world',
            'description' => $attributes['description'] ?? 'General supportive conversation.',
            'icon_key' => $attributes['icon_key'] ?? 'globe',
            'is_active' => $attributes['is_active'] ?? true,
            'sort_order' => $attributes['sort_order'] ?? 1,
        ]);
    }

    private function identity(User $user): CommunityIdentity
    {
        return CommunityIdentity::firstOrCreate([
            'user_id' => $user->id,
            'is_active' => true,
        ], [
            'anonymous_name' => 'QuietMind'.random_int(1000, 9999),
            'anonymous_code' => (string) Str::uuid(),
            'avatar_seed' => Str::lower(Str::random(12)),
        ]);
    }

    private function message(CommunityRoom $room, CommunityIdentity $identity, array $attributes = []): CommunityMessage
    {
        return CommunityMessage::create([
            'room_id' => $room->id,
            'community_identity_id' => $identity->id,
            'parent_id' => $attributes['parent_id'] ?? null,
            'body' => $attributes['body'] ?? 'I am having a difficult day today.',
            'status' => $attributes['status'] ?? CommunityMessage::STATUS_PUBLISHED,
            'created_at' => $attributes['created_at'] ?? now(),
            'updated_at' => $attributes['updated_at'] ?? now(),
        ]);
    }

    private function actingWithToken(User $user): self
    {
        return $this->withHeader('Authorization', 'Bearer '.$user->api_token);
    }
}
