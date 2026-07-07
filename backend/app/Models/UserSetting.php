<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'daily_reminders', 'reminder_time', 'notification_channels', 'theme_mode', 'privacy_options_json'])]
class UserSetting extends Model
{
    protected function casts(): array
    {
        return [
            'daily_reminders' => 'boolean',
            'notification_channels' => 'array',
            'privacy_options_json' => 'array',
        ];
    }
}
