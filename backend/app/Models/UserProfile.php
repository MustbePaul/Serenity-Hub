<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'phone', 'gender', 'date_of_birth', 'emergency_contact_name', 'emergency_contact_phone', 'avatar_url', 'privacy_consent_at'])]
class UserProfile extends Model
{
    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'privacy_consent_at' => 'datetime',
        ];
    }
}
