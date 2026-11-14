<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['user_id', 'resource_id'])]
class Bookmark extends Model
{
    public function resource(): BelongsTo
    {
        return $this->belongsTo(Resource::class);
    }
}
