<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'community_identity_id',
    'state',
    'reason',
    'applied_by',
    'starts_at',
    'expires_at',
    'removed_at',
    'removed_by',
])]
class CommunityPostingRestriction extends Model
{
    public const STATE_TEMPORARY = 'temporary';
    public const STATE_INDEFINITE = 'indefinite';

    protected function casts(): array
    {
        return [
            'starts_at' => 'datetime',
            'expires_at' => 'datetime',
            'removed_at' => 'datetime',
        ];
    }

    public function isActive(): bool
    {
        return $this->removed_at === null
            && ($this->expires_at === null || $this->expires_at->isFuture());
    }

    public function communityIdentity(): BelongsTo
    {
        return $this->belongsTo(CommunityIdentity::class, 'community_identity_id');
    }
}
