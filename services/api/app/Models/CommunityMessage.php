<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'room_id',
    'community_identity_id',
    'parent_id',
    'body',
    'status',
    'safety_flags_json',
    'edited_at',
    'reviewed_at',
    'reviewed_by',
    'moderation_notes',
])]
class CommunityMessage extends Model
{
    use SoftDeletes;

    public const STATUS_PUBLISHED = 'published';
    public const STATUS_HIDDEN = 'hidden';
    public const STATUS_REMOVED = 'removed';
    public const STATUS_UNDER_REVIEW = 'under_review';

    protected function casts(): array
    {
        return [
            'safety_flags_json' => 'array',
            'edited_at' => 'datetime',
            'reviewed_at' => 'datetime',
        ];
    }

    public function room(): BelongsTo
    {
        return $this->belongsTo(CommunityRoom::class, 'room_id');
    }

    public function identity(): BelongsTo
    {
        return $this->belongsTo(CommunityIdentity::class, 'community_identity_id');
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(self::class, 'parent_id');
    }

    public function replies(): HasMany
    {
        return $this->hasMany(self::class, 'parent_id');
    }

    public function reactions(): HasMany
    {
        return $this->hasMany(CommunityReaction::class, 'message_id');
    }
}
