<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['resource_id', 'media_asset_id', 'sort_order'])]
class ResourceMedia extends Model
{
    protected $table = 'resource_media';

    public function resource(): BelongsTo
    {
        return $this->belongsTo(Resource::class);
    }

    public function mediaAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class);
    }
}
