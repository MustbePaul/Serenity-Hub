<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['user_id', 'media_asset_id', 'resource_id', 'wellness_session_id', 'progress_seconds', 'duration_seconds', 'progress_percent', 'is_completed', 'last_played_at', 'completed_at'])]
class UserMediaProgress extends Model
{
    protected $table = 'user_media_progress';

    protected function casts(): array
    {
        return [
            'progress_seconds' => 'integer',
            'duration_seconds' => 'integer',
            'progress_percent' => 'float',
            'is_completed' => 'boolean',
            'last_played_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function mediaAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class);
    }

    public function resource(): BelongsTo
    {
        return $this->belongsTo(Resource::class);
    }

    public function wellnessSession(): BelongsTo
    {
        return $this->belongsTo(WellnessSession::class);
    }
}
