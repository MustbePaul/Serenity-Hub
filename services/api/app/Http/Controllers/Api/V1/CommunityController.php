<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\CommunityBlock;
use App\Models\CommunityIdentity;
use App\Models\CommunityMessage;
use App\Events\CommunityMessageCreated;
use App\Events\CommunityMessageRemoved;
use App\Events\CommunityReactionUpdated;
use App\Models\CommunityReport;
use App\Models\CommunityRoom;
use App\Models\CommunityPostingRestriction;
use App\Models\CommunityReaction;
use App\Models\User;
use App\Services\CommunitySafetyService;
use App\Support\CommunityMessagePayload;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class CommunityController extends ApiController
{
    public function __construct(private readonly CommunitySafetyService $safetyService)
    {
    }

    public function me(Request $request)
    {
        return $this->success($this->identityPayload($this->identityFor($request->user())));
    }

    public function rooms()
    {
        return $this->success(CommunityRoom::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get(['id', 'name', 'slug', 'description', 'icon_key', 'sort_order']));
    }

    public function messages(Request $request, CommunityRoom $room)
    {
        abort_unless($room->is_active, 404);

        $identity = $this->identityFor($request->user());
        $messages = $this->visibleMessagesQuery($identity)
            ->where('room_id', $room->id)
            ->whereNull('parent_id')
            ->latest()
            ->paginate(min($request->integer('per_page', 30), 30));

        return $this->paginatedMessages($messages, $identity);
    }

    public function storeMessage(Request $request, CommunityRoom $room)
    {
        abort_unless($room->is_active, 404);

        $request->merge(['body' => trim((string) $request->input('body'))]);
        $data = $request->validate([
            'body' => ['required', 'string', 'max:2000'],
        ]);

        $identity = $this->identityFor($request->user());
        if ($restriction = $this->activeRestriction($identity)) {
            return $this->restrictedResponse($restriction);
        }

        abort_if($this->isRepeatedMessage($identity, $data['body']), 429, 'Please slow down before posting the same message again.');

        $safety = $this->safetyService->classify($data['body']);

        $message = CommunityMessage::create([
            'room_id' => $room->id,
            'community_identity_id' => $identity->id,
            'body' => $data['body'],
            'status' => $safety['requires_review'] ? CommunityMessage::STATUS_UNDER_REVIEW : CommunityMessage::STATUS_PUBLISHED,
            'safety_flags_json' => $safety['flags'],
        ]);

        CommunityMessageCreated::dispatch($message->load(['identity', 'room']));

        return $this->success([
            'message' => $this->messagePayload($message->load('identity'), $identity),
            'safety' => [
                'flags' => $safety['flags'],
                'requires_review' => $safety['requires_review'],
                'supportive_notice' => $safety['supportive_notice'],
            ],
        ], 'Message posted.', status: 201);
    }

    public function replies(Request $request, CommunityMessage $message)
    {
        $identity = $this->identityFor($request->user());
        abort_unless($this->canSeeMessage($message, $identity), 404);

        $replies = $this->visibleMessagesQuery($identity)
            ->where('parent_id', $message->id)
            ->oldest()
            ->paginate(min($request->integer('per_page', 30), 30));

        return $this->paginatedMessages($replies, $identity);
    }

    public function storeReply(Request $request, CommunityMessage $message)
    {
        $identity = $this->identityFor($request->user());
        abort_unless($this->canSeeMessage($message, $identity), 404);
        abort_if($message->parent_id !== null, 422, 'Only one reply level is supported.');

        $request->merge(['body' => trim((string) $request->input('body'))]);
        $data = $request->validate([
            'body' => ['required', 'string', 'max:2000'],
        ]);

        if ($restriction = $this->activeRestriction($identity)) {
            return $this->restrictedResponse($restriction);
        }

        abort_if($this->isRepeatedMessage($identity, $data['body']), 429, 'Please slow down before posting the same message again.');

        $safety = $this->safetyService->classify($data['body']);
        $reply = CommunityMessage::create([
            'room_id' => $message->room_id,
            'community_identity_id' => $identity->id,
            'parent_id' => $message->id,
            'body' => $data['body'],
            'status' => $safety['requires_review'] ? CommunityMessage::STATUS_UNDER_REVIEW : CommunityMessage::STATUS_PUBLISHED,
            'safety_flags_json' => $safety['flags'],
        ]);

        CommunityMessageCreated::dispatch($reply->load(['identity', 'room']));

        return $this->success([
            'message' => $this->messagePayload($reply->load('identity'), $identity),
            'safety' => [
                'flags' => $safety['flags'],
                'requires_review' => $safety['requires_review'],
                'supportive_notice' => $safety['supportive_notice'],
            ],
        ], 'Reply posted.', status: 201);
    }

    public function react(Request $request, CommunityMessage $message)
    {
        $identity = $this->identityFor($request->user());
        abort_unless($this->canSeeMessage($message, $identity), 404);

        $data = $request->validate([
            'reaction' => ['required', Rule::in(CommunityReaction::TYPES)],
        ]);

        CommunityReaction::firstOrCreate([
            'message_id' => $message->id,
            'community_identity_id' => $identity->id,
            'reaction' => $data['reaction'],
        ]);

        CommunityReactionUpdated::dispatch($message->fresh('room'));

        return $this->success($this->messagePayload($message->fresh('identity'), $identity), 'Reaction saved.');
    }

    public function removeReaction(Request $request, CommunityMessage $message, string $reaction)
    {
        $identity = $this->identityFor($request->user());
        abort_unless(in_array($reaction, CommunityReaction::TYPES, true), 404);

        CommunityReaction::query()
            ->where('message_id', $message->id)
            ->where('community_identity_id', $identity->id)
            ->where('reaction', $reaction)
            ->delete();

        CommunityReactionUpdated::dispatch($message->fresh('room'));

        return $this->success($this->messagePayload($message->fresh('identity'), $identity), 'Reaction removed.');
    }

    public function report(Request $request, CommunityMessage $message)
    {
        $identity = $this->identityFor($request->user());
        abort_unless($this->canSeeMessage($message, $identity), 404);

        $data = $request->validate([
            'reason' => ['required', Rule::in(CommunityReport::REASONS)],
            'details' => ['nullable', 'string', 'max:1000'],
        ]);

        $report = CommunityReport::firstOrCreate([
            'message_id' => $message->id,
            'reporter_community_identity_id' => $identity->id,
            'reason' => $data['reason'],
        ], [
            'reported_community_identity_id' => $message->community_identity_id,
            'details' => $data['details'] ?? null,
            'status' => 'pending',
        ]);

        return $this->success([
            'id' => $report->id,
            'status' => $report->status,
            'reason' => $report->reason,
        ], 'Report submitted.', status: 201);
    }

    public function block(Request $request, string $anonymousCode)
    {
        $identity = $this->identityFor($request->user());
        $blocked = CommunityIdentity::where('anonymous_code', $anonymousCode)->where('is_active', true)->firstOrFail();
        abort_if($blocked->id === $identity->id, 422, 'You cannot block your own identity.');

        CommunityBlock::firstOrCreate([
            'blocker_community_identity_id' => $identity->id,
            'blocked_community_identity_id' => $blocked->id,
        ]);

        return $this->success(null, 'Identity blocked.');
    }

    public function unblock(Request $request, string $anonymousCode)
    {
        $identity = $this->identityFor($request->user());
        $blocked = CommunityIdentity::where('anonymous_code', $anonymousCode)->firstOrFail();

        CommunityBlock::query()
            ->where('blocker_community_identity_id', $identity->id)
            ->where('blocked_community_identity_id', $blocked->id)
            ->delete();

        return $this->success(null, 'Identity unblocked.');
    }

    public function destroy(Request $request, CommunityMessage $message)
    {
        $identity = $this->identityFor($request->user());
        abort_unless($message->community_identity_id === $identity->id, 404);

        $message->update([
            'status' => CommunityMessage::STATUS_REMOVED,
            'moderation_notes' => 'Removed by author.',
        ]);

        CommunityMessageRemoved::dispatch($message->fresh('room'));

        return $this->success(null, 'Message removed.');
    }

    private function identityFor(User $user): CommunityIdentity
    {
        $existing = CommunityIdentity::query()
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->first();

        if ($existing) {
            return $existing;
        }

        return DB::transaction(function () use ($user) {
            $existing = CommunityIdentity::query()
                ->where('user_id', $user->id)
                ->where('is_active', true)
                ->lockForUpdate()
                ->first();

            if ($existing) {
                return $existing;
            }

            return CommunityIdentity::create([
                'user_id' => $user->id,
                'anonymous_name' => $this->anonymousName(),
                'anonymous_code' => (string) Str::uuid(),
                'avatar_seed' => Str::lower(Str::random(12)),
                'is_active' => true,
            ]);
        });
    }

    private function anonymousName(): string
    {
        $names = ['QuietMind', 'BlueSky', 'GreenLeaf', 'Moonlight', 'CalmRiver', 'GentleSoul', 'BrightStar', 'HopefulHeart'];

        for ($attempt = 0; $attempt < 20; $attempt++) {
            $name = $names[array_rand($names)].random_int(10, 9999);
            if (! CommunityIdentity::where('anonymous_name', $name)->exists()) {
                return $name;
            }
        }

        return 'QuietMind'.Str::upper(Str::random(8));
    }

    private function visibleMessagesQuery(CommunityIdentity $identity)
    {
        $blockedIds = CommunityBlock::query()
            ->where('blocker_community_identity_id', $identity->id)
            ->pluck('blocked_community_identity_id');

        return CommunityMessage::query()
            ->with(['identity', 'reactions'])
            ->withCount([
                'replies as published_replies_count' => fn ($query) => $query->where('status', CommunityMessage::STATUS_PUBLISHED),
            ])
            ->where('status', CommunityMessage::STATUS_PUBLISHED)
            ->whereNotIn('community_identity_id', $blockedIds);
    }

    private function canSeeMessage(CommunityMessage $message, CommunityIdentity $identity): bool
    {
        if ($message->status !== CommunityMessage::STATUS_PUBLISHED && $message->community_identity_id !== $identity->id) {
            return false;
        }

        return ! CommunityBlock::query()
            ->where('blocker_community_identity_id', $identity->id)
            ->where('blocked_community_identity_id', $message->community_identity_id)
            ->exists();
    }

    private function paginatedMessages($messages, CommunityIdentity $identity)
    {
        return $this->success(collect($messages->items())->map(fn ($message) => $this->messagePayload($message, $identity))->values(), meta: [
            'current_page' => $messages->currentPage(),
            'last_page' => $messages->lastPage(),
            'total' => $messages->total(),
        ]);
    }

    private function messagePayload(CommunityMessage $message, CommunityIdentity $viewer): array
    {
        return CommunityMessagePayload::forViewer($message, $viewer);
    }

    private function identityPayload(CommunityIdentity $identity): array
    {
        return CommunityMessagePayload::identity($identity);
    }

    private function activeRestriction(CommunityIdentity $identity): ?CommunityPostingRestriction
    {
        return CommunityPostingRestriction::query()
            ->where('community_identity_id', $identity->id)
            ->whereNull('removed_at')
            ->where(function ($query) {
                $query->whereNull('expires_at')->orWhere('expires_at', '>', now());
            })
            ->latest()
            ->first();
    }

    private function restrictedResponse(CommunityPostingRestriction $restriction)
    {
        $message = "You can't post in Serenity Circle right now.";
        if ($restriction->expires_at) {
            $message .= ' You can try again after '.$restriction->expires_at->toISOString().'.';
        }

        return $this->error($message, status: 403);
    }

    private function isRepeatedMessage(CommunityIdentity $identity, string $body): bool
    {
        return CommunityMessage::query()
            ->where('community_identity_id', $identity->id)
            ->where('body', $body)
            ->where('created_at', '>=', now()->subMinutes(2))
            ->exists();
    }
}
