<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['message_id', 'community_identity_id', 'reaction'])]
class CommunityReaction extends Model
{
    public const TYPES = ['support', 'relate', 'encouragement', 'hug'];

    public function message(): BelongsTo
    {
        return $this->belongsTo(CommunityMessage::class, 'message_id');
    }

    public function identity(): BelongsTo
    {
        return $this->belongsTo(CommunityIdentity::class, 'community_identity_id');
    }
}
