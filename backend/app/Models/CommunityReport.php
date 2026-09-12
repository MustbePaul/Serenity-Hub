<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'message_id',
    'reporter_community_identity_id',
    'reported_community_identity_id',
    'reason',
    'details',
    'status',
    'moderator_notes',
])]
class CommunityReport extends Model
{
    public const REASONS = [
        'harassment',
        'bullying',
        'hate',
        'spam',
        'sexual_content',
        'self_harm_concern',
        'threat_or_violence',
        'privacy_or_personal_information',
        'misinformation_or_harmful_advice',
        'other',
    ];

    public function message(): BelongsTo
    {
        return $this->belongsTo(CommunityMessage::class, 'message_id');
    }

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(CommunityIdentity::class, 'reporter_community_identity_id');
    }

    public function reported(): BelongsTo
    {
        return $this->belongsTo(CommunityIdentity::class, 'reported_community_identity_id');
    }
}
