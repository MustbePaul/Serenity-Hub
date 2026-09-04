<?php

namespace Tests\Feature;

use App\Models\Appointment;
use App\Models\AvailabilitySlot;
use App\Models\Resource;
use App\Models\ResourceCategory;
use App\Models\TherapistProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class IntegrationCompletionTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_request_succeeds_and_protected_requests_reject_missing_or_invalid_tokens(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('data.email', $user->email);

        $this->withHeader('Authorization', '')
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Unauthenticated.');

        $this->withHeader('Authorization', 'Bearer invalid-token')
            ->getJson('/api/v1/auth/me')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Invalid or expired token.');
    }

    public function test_user_can_book_available_slot_and_see_it_in_appointment_history(): void
    {
        [$user, $therapist, $slot] = $this->bookingFixture();

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/appointments', [
                'therapist_id' => $therapist->id,
                'availability_slot_id' => $slot->id,
                'mode' => 'online',
                'reason' => 'Initial consultation',
            ])
            ->assertCreated()
            ->assertJsonPath('data.therapist.user.name', 'Dr Test');

        $this->assertDatabaseHas('appointments', [
            'user_id' => $user->id,
            'therapist_id' => $therapist->id,
            'availability_slot_id' => $slot->id,
            'status' => 'confirmed',
        ]);
        $this->assertDatabaseHas('availability_slots', [
            'id' => $slot->id,
            'status' => 'booked',
        ]);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->getJson('/api/v1/appointments')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.reason', 'Initial consultation');
    }

    public function test_appointment_creation_validates_fields_and_rejects_unavailable_or_double_booked_slots(): void
    {
        [$user, $therapist, $slot] = $this->bookingFixture();

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/appointments', [])
            ->assertUnprocessable();

        $slot->update(['status' => 'booked']);
        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/appointments', [
                'therapist_id' => $therapist->id,
                'availability_slot_id' => $slot->id,
                'mode' => 'online',
            ])
            ->assertConflict();

        $slot->update(['status' => 'available']);
        Appointment::create([
            'user_id' => $user->id,
            'therapist_id' => $therapist->id,
            'availability_slot_id' => null,
            'scheduled_start' => $slot->starts_at,
            'scheduled_end' => $slot->ends_at,
            'mode' => 'online',
            'status' => 'confirmed',
        ]);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/appointments', [
                'therapist_id' => $therapist->id,
                'availability_slot_id' => $slot->id,
                'mode' => 'online',
            ])
            ->assertConflict();
    }

    public function test_appointment_history_only_contains_authenticated_users_appointments(): void
    {
        [$user, $therapist, $slot] = $this->bookingFixture();
        $otherUser = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);
        $otherSlot = AvailabilitySlot::create([
            'therapist_id' => $therapist->id,
            'starts_at' => now()->addDays(3),
            'ends_at' => now()->addDays(3)->addHour(),
            'status' => 'available',
        ]);

        Appointment::create([
            'user_id' => $user->id,
            'therapist_id' => $therapist->id,
            'availability_slot_id' => $slot->id,
            'scheduled_start' => $slot->starts_at,
            'scheduled_end' => $slot->ends_at,
            'mode' => 'phone',
            'status' => 'confirmed',
        ]);
        Appointment::create([
            'user_id' => $otherUser->id,
            'therapist_id' => $therapist->id,
            'availability_slot_id' => $otherSlot->id,
            'scheduled_start' => $otherSlot->starts_at,
            'scheduled_end' => $otherSlot->ends_at,
            'mode' => 'online',
            'status' => 'confirmed',
        ]);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->getJson('/api/v1/appointments')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.mode', 'phone');
    }

    public function test_mood_checkins_validate_and_belong_to_authenticated_user(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/mood-checkins', ['mood_score' => 5, 'tags' => ['calm']])
            ->assertCreated()
            ->assertJsonPath('data.user_id', $user->id);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/mood-checkins', ['mood_score' => 8])
            ->assertUnprocessable();
    }

    public function test_bookmarks_can_be_created_listed_removed_and_deduplicated(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);
        $resource = $this->resourceFixture();

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson("/api/v1/resources/{$resource->id}/bookmark")
            ->assertOk();
        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson("/api/v1/resources/{$resource->id}/bookmark")
            ->assertOk();

        $this->assertDatabaseCount('bookmarks', 1);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->getJson('/api/v1/bookmarks')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.resource.title', 'Grounding');

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->deleteJson("/api/v1/resources/{$resource->id}/bookmark")
            ->assertOk();

        $this->assertDatabaseCount('bookmarks', 0);
    }

    public function test_support_ticket_validation_and_authenticated_association(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/support-tickets', [
                'subject' => 'Help',
                'message' => 'I need help with booking.',
                'priority' => 'urgent',
            ])
            ->assertCreated()
            ->assertJsonPath('data.user_id', $user->id);

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->postJson('/api/v1/support-tickets', [
                'subject' => 'Help',
                'message' => 'short',
            ])
            ->assertUnprocessable();
    }

    public function test_profile_update_validates_fields_and_requires_authentication(): void
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active', 'name' => 'Old Name']);

        $this->patchJson('/api/v1/profile', ['name' => 'New Name'])
            ->assertUnauthorized();

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->patchJson('/api/v1/profile', [
                'name' => 'New Name',
                'phone' => '+265990000000',
                'date_of_birth' => 'not-a-date',
            ])
            ->assertUnprocessable();

        $this->withHeader('Authorization', 'Bearer '.$user->api_token)
            ->patchJson('/api/v1/profile', [
                'name' => 'New Name',
                'phone' => '+265990000000',
                'gender' => 'female',
                'date_of_birth' => '1995-01-15',
                'emergency_contact_name' => 'Friend',
                'emergency_contact_phone' => '+265991111111',
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'New Name')
            ->assertJsonPath('data.profile.phone', '+265990000000');

        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $user->id,
            'phone' => '+265990000000',
        ]);
    }

    private function bookingFixture(): array
    {
        $user = User::factory()->create(['api_token' => Str::random(40), 'status' => 'active']);
        $therapistUser = User::factory()->create(['name' => 'Dr Test', 'role' => 'therapist']);
        $therapist = TherapistProfile::create([
            'user_id' => $therapistUser->id,
            'license_number' => 'TEST-'.Str::random(8),
            'verification_status' => 'approved',
            'session_modes' => ['online', 'phone'],
        ]);
        $slot = AvailabilitySlot::create([
            'therapist_id' => $therapist->id,
            'starts_at' => now()->addDays(2),
            'ends_at' => now()->addDays(2)->addHour(),
            'status' => 'available',
            'timezone' => 'Africa/Blantyre',
        ]);

        return [$user, $therapist, $slot];
    }

    private function resourceFixture(): Resource
    {
        $category = ResourceCategory::create([
            'name' => 'Stress',
            'slug' => 'stress',
        ]);

        return Resource::create([
            'category_id' => $category->id,
            'title' => 'Grounding',
            'slug' => 'grounding',
            'summary' => 'A grounding resource.',
            'body' => 'Grounding details.',
            'status' => 'published',
            'published_at' => now(),
        ]);
    }
}
