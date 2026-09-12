<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['blocker_community_identity_id', 'blocked_community_identity_id'])]
class CommunityBlock extends Model
{
    //
}
