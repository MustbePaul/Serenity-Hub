<?php

namespace App\Support;

use App\Models\CommunityIdentity;
use App\Models\CommunityMessage;
use App\Models\CommunityReaction;
use Illuminate\Support\Facades\DB;

class CommunityMessagePayload
{
    public static function forViewer(CommunityMessage $message, CommunityIdentity $viewer): array
    {
        return self::build($message, $viewer, includeMine: true);
    }

    public static function forBroadcast(CommunityMessage $message): array
    {
        return self::build($message, null, includeMine: false);
    }

    public static function reactionSummary(CommunityMessage $message): array
    {
        $reactionCounts = $message->relationLoaded('reactions')
            ? $message->reactions->countBy('reaction')
            : CommunityReaction::query()
                ->select('reaction', DB::raw('count(*) as aggregate'))
                ->where('message_id', $message->id)
                ->groupBy('reaction')
                ->pluck('aggregate', 'reaction');

        return collect(CommunityReaction::TYPES)
            ->mapWithKeys(fn ($reaction) => [$reaction => (int) ($reactionCounts[$reaction] ?? 0)])
            ->all();
    }

    public static function identity(CommunityIdentity $identity): array
    {
        return [
            'id' => $identity->anonymous_code,
            'display_name' => $identity->anonymous_name,
            'avatar_seed' => $identity->avatar_seed,
        ];
    }

    private static function build(CommunityMessage $message, ?CommunityIdentity $viewer, bool $includeMine): array
    {
        $message->loadMissing('identity');

        $myReactions = [];
        if ($includeMine && $viewer) {
            $myReactions = CommunityReaction::query()
                ->where('message_id', $message->id)
                ->where('community_identity_id', $viewer->id)
                ->pluck('reaction')
                ->values()
                ->all();
        }

        $isMine = $viewer && $message->community_identity_id === $viewer->id;

        return [
            'id' => $message->id,
            'parent_id' => $message->parent_id,
            'body' => $message->status === CommunityMessage::STATUS_REMOVED ? null : $message->body,
            'anonymous_identity' => self::identity($message->identity),
            'reactions' => self::reactionSummary($message),
            'my_reactions' => $myReactions,
            'reply_count' => (int) ($message->published_replies_count ?? CommunityMessage::query()
                ->where('parent_id', $message->id)
                ->where('status', CommunityMessage::STATUS_PUBLISHED)
                ->count()),
            'is_mine' => (bool) $isMine,
            'status' => $isMine ? $message->status : CommunityMessage::STATUS_PUBLISHED,
            'created_at' => $message->created_at?->toISOString(),
            'edited_at' => $message->edited_at?->toISOString(),
        ];
    }
}
