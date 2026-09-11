<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'country_code',
    'country_name',
    'service_name',
    'description',
    'phone_number',
    'whatsapp_number',
    'sms_number',
    'website_url',
    'email',
    'availability_text',
    'is_emergency_service',
    'is_crisis_support',
    'is_active',
    'display_order',
])]
class SupportContact extends Model
{
    protected function casts(): array
    {
        return [
            'is_emergency_service' => 'boolean',
            'is_crisis_support' => 'boolean',
            'is_active' => 'boolean',
            'display_order' => 'integer',
        ];
    }
}
