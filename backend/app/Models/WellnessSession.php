<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'title',
    'description',
    'category',
    'session_type',
    'instructions',
    'transcript',
    'breathing_pattern',
    'inhale_seconds',
    'hold_seconds',
    'exhale_seconds',
    'second_hold_seconds',
    'target_mood',
    'difficulty',
    'estimated_duration_seconds',
    'resource_id',
    'media_asset_id',
    'background_audio_media_id',
    'narration_media_id',
    'demonstration_video_media_id',
    'is_featured',
    'supports_offline',
    'status',
])]
class WellnessSession extends Model
{
    protected function casts(): array
    {
        return [
            'estimated_duration_seconds' => 'integer',
            'is_featured' => 'boolean',
            'supports_offline' => 'boolean',
            'inhale_seconds' => 'integer',
            'hold_seconds' => 'integer',
            'exhale_seconds' => 'integer',
            'second_hold_seconds' => 'integer',
        ];
    }

    public function mediaAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class);
    }

    public function resource(): BelongsTo
    {
        return $this->belongsTo(Resource::class);
    }

    public function backgroundAudio(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'background_audio_media_id');
    }

    public function narrationMedia(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'narration_media_id');
    }

    public function demonstrationVideo(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'demonstration_video_media_id');
    }
}
