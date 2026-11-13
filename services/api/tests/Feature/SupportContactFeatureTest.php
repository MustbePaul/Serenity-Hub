<?php

namespace Tests\Feature;

use App\Models\SupportContact;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SupportContactFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_it_lists_only_active_support_contacts(): void
    {
        SupportContact::create([
            'country_code' => 'ZZ',
            'country_name' => 'Demo Country',
            'service_name' => 'DEMO ONLY - Active service',
            'is_active' => true,
        ]);
        SupportContact::create([
            'country_code' => 'ZZ',
            'country_name' => 'Demo Country',
            'service_name' => 'Inactive service',
            'is_active' => false,
        ]);

        $this->getJson('/api/v1/support-contacts')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.service_name', 'DEMO ONLY - Active service');
    }

    public function test_it_filters_support_contacts_by_country_and_type(): void
    {
        SupportContact::create([
            'country_code' => 'ZZ',
            'country_name' => 'Demo Country',
            'service_name' => 'Emergency placeholder',
            'is_emergency_service' => true,
            'is_crisis_support' => false,
        ]);
        SupportContact::create([
            'country_code' => 'AA',
            'country_name' => 'Another Demo Country',
            'service_name' => 'Crisis placeholder',
            'is_emergency_service' => false,
            'is_crisis_support' => true,
        ]);

        $this->getJson('/api/v1/support-contacts?country_code=zz&is_emergency_service=1')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.country_code', 'ZZ')
            ->assertJsonPath('data.0.is_emergency_service', true);
    }

    public function test_inactive_support_contact_detail_is_hidden(): void
    {
        $contact = SupportContact::create([
            'country_code' => 'ZZ',
            'country_name' => 'Demo Country',
            'service_name' => 'Inactive service',
            'is_active' => false,
        ]);

        $this->getJson("/api/v1/support-contacts/{$contact->id}")
            ->assertNotFound();
    }
}
