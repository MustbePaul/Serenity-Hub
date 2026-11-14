<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'mood_score', 'tags', 'note', 'checked_in_at'])]
class MoodCheckin extends Model
{
    protected function casts(): array
    {
        return [
            'tags' => 'array',
            'checked_in_at' => 'datetime',
        ];
    }
}
