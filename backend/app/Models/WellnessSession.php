<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['title', 'description', 'category', 'target_mood', 'difficulty', 'estimated_duration_seconds', 'resource_id', 'media_asset_id', 'is_featured', 'status'])]
class WellnessSession extends Model
{
    protected function casts(): array
    {
        return [
            'estimated_duration_seconds' => 'integer',
            'is_featured' => 'boolean',
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
}
