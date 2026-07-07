<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'therapist_id', 'availability_slot_id', 'scheduled_start', 'scheduled_end', 'mode', 'location_or_link', 'reason', 'status'])]
class Appointment extends Model
{
    protected function casts(): array
    {
        return [
            'scheduled_start' => 'datetime',
            'scheduled_end' => 'datetime',
        ];
    }
}
