<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['title', 'description', 'media_type', 'file_url', 'thumbnail_url', 'duration_seconds', 'language', 'transcript', 'storage_disk', 'status', 'created_by'])]
class MediaAsset extends Model
{
    protected function casts(): array
    {
        return [
            'duration_seconds' => 'integer',
        ];
    }

    public function resources(): BelongsToMany
    {
        return $this->belongsToMany(Resource::class, 'resource_media')
            ->withPivot('sort_order')
            ->withTimestamps();
    }

    public function progress(): HasMany
    {
        return $this->hasMany(UserMediaProgress::class);
    }
}
