<?php

namespace Tests\Feature;

use Tests\TestCase;

class UssdFeatureTest extends TestCase
{
    public function test_it_starts_a_plain_text_ussd_session(): void
    {
        $response = $this->post('/api/ussd', [
            'sessionId' => 'review-session',
            'serviceCode' => '*123#',
            'phoneNumber' => '+265990000000',
            'text' => '',
        ]);

        $response->assertOk()
            ->assertHeader('content-type', 'text/plain; charset=UTF-8')
            ->assertSeeText('CON Serenity Hub');
    }

    public function test_it_returns_a_safety_message_for_immediate_danger(): void
    {
        $this->post('/api/ussd', ['text' => '3*3'])
            ->assertOk()
            ->assertSeeText('END If anyone is in immediate danger');
    }
}
