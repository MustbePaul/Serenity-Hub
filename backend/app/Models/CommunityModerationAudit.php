<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'action',
    'actor_user_id',
    'community_message_id',
    'community_report_id',
    'community_identity_id',
    'metadata',
])]
class CommunityModerationAudit extends Model
{
    protected function casts(): array
    {
        return [
            'metadata' => 'array',
        ];
    }
}
