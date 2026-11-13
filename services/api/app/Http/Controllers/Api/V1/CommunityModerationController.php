<?php

namespace App\Http\Controllers\Api\V1;

use App\Events\CommunityMessageRemoved;
use App\Models\CommunityIdentity;
use App\Models\CommunityMessage;
use App\Models\CommunityModerationAudit;
use App\Models\CommunityPostingRestriction;
use App\Models\CommunityReport;
use App\Support\CommunityMessagePayload;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CommunityModerationController extends ApiController
{
    public function reports(Request $request)
    {
        $status = $request->query('status', 'pending');

        $reports = CommunityReport::query()
            ->with(['message.identity', 'message.room', 'reporter', 'reported'])
            ->when($status !== 'all', fn ($query) => $query->where('status', $status))
            ->latest()
            ->paginate(min($request->integer('per_page', 30), 50));

        return $this->success(collect($reports->items())->map(fn ($report) => $this->reportPayload($report))->values(), meta: [
            'current_page' => $reports->currentPage(),
            'last_page' => $reports->lastPage(),
            'total' => $reports->total(),
        ]);
    }

    public function report(CommunityReport $report)
    {
        return $this->success($this->reportPayload($report->load(['message.identity', 'message.room', 'reporter', 'reported'])));
    }

    public function updateReport(Request $request, CommunityReport $report)
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['reviewing', 'resolved', 'dismissed'])],
            'moderator_notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $report->update($data);
        $this->audit($request, 'report_'.$data['status'], report: $report);

        return $this->success($this->reportPayload($report->fresh(['message.identity', 'message.room', 'reporter', 'reported'])));
    }

    public function hideMessage(Request $request, CommunityMessage $message)
    {
        return $this->moderateMessage($request, $message, CommunityMessage::STATUS_HIDDEN, 'message_hidden');
    }

    public function restoreMessage(Request $request, CommunityMessage $message)
    {
        return $this->moderateMessage($request, $message, CommunityMessage::STATUS_PUBLISHED, 'message_restored');
    }

    public function removeMessage(Request $request, CommunityMessage $message)
    {
        return $this->moderateMessage($request, $message, CommunityMessage::STATUS_REMOVED, 'message_removed');
    }

    public function restrictPosting(Request $request, string $anonymousCode)
    {
        $identity = CommunityIdentity::query()->where('anonymous_code', $anonymousCode)->firstOrFail();
        $data = $request->validate([
            'state' => ['required', Rule::in([CommunityPostingRestriction::STATE_TEMPORARY, CommunityPostingRestriction::STATE_INDEFINITE])],
            'reason' => ['nullable', 'string', 'max:2000'],
            'expires_at' => ['nullable', 'date', 'after:now'],
        ]);

        $restriction = CommunityPostingRestriction::create([
            'community_identity_id' => $identity->id,
            'state' => $data['state'],
            'reason' => $data['reason'] ?? null,
            'applied_by' => $request->user()->id,
            'starts_at' => now(),
            'expires_at' => $data['state'] === CommunityPostingRestriction::STATE_TEMPORARY ? ($data['expires_at'] ?? now()->addDay()) : null,
        ]);

        $this->audit($request, 'posting_restriction_applied', identity: $identity, metadata: ['state' => $restriction->state]);

        return $this->success($this->restrictionPayload($restriction), 'Posting restriction applied.', status: 201);
    }

    public function restorePosting(Request $request, string $anonymousCode)
    {
        $identity = CommunityIdentity::query()->where('anonymous_code', $anonymousCode)->firstOrFail();

        CommunityPostingRestriction::query()
            ->where('community_identity_id', $identity->id)
            ->whereNull('removed_at')
            ->update(['removed_at' => now(), 'removed_by' => $request->user()->id]);

        $this->audit($request, 'posting_restriction_removed', identity: $identity);

        return $this->success(null, 'Posting privileges restored.');
    }

    private function moderateMessage(Request $request, CommunityMessage $message, string $status, string $action)
    {
        $data = $request->validate([
            'moderation_notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $message->update([
            'status' => $status,
            'reviewed_at' => now(),
            'reviewed_by' => $request->user()->id,
            'moderation_notes' => $data['moderation_notes'] ?? $message->moderation_notes,
        ]);

        $this->audit($request, $action, message: $message);

        if (in_array($status, [CommunityMessage::STATUS_HIDDEN, CommunityMessage::STATUS_REMOVED], true)) {
            CommunityMessageRemoved::dispatch($message->fresh('room'));
        }

        return $this->success(['message' => $this->moderationMessagePayload($message->fresh(['identity', 'room']))]);
    }

    private function reportPayload(CommunityReport $report): array
    {
        return [
            'id' => $report->id,
            'status' => $report->status,
            'reason' => $report->reason,
            'details' => $report->details,
            'moderator_notes' => $report->moderator_notes,
            'message' => $report->message ? $this->moderationMessagePayload($report->message) : null,
            'reporter_identity' => $report->reporter ? CommunityMessagePayload::identity($report->reporter) : null,
            'reported_identity' => $report->reported ? CommunityMessagePayload::identity($report->reported) : null,
            'created_at' => $report->created_at?->toISOString(),
        ];
    }

    private function moderationMessagePayload(CommunityMessage $message): array
    {
        return [
            'id' => $message->id,
            'body' => $message->body,
            'status' => $message->status,
            'room' => ['slug' => $message->room?->slug, 'name' => $message->room?->name],
            'anonymous_identity' => CommunityMessagePayload::identity($message->identity),
            'safety_flags' => $message->safety_flags_json ?? [],
            'created_at' => $message->created_at?->toISOString(),
            'reviewed_at' => $message->reviewed_at?->toISOString(),
        ];
    }

    private function restrictionPayload(CommunityPostingRestriction $restriction): array
    {
        return [
            'id' => $restriction->id,
            'identity_id' => $restriction->communityIdentity?->anonymous_code,
            'state' => $restriction->state,
            'starts_at' => $restriction->starts_at?->toISOString(),
            'expires_at' => $restriction->expires_at?->toISOString(),
            'removed_at' => $restriction->removed_at?->toISOString(),
        ];
    }

    private function audit(
        Request $request,
        string $action,
        ?CommunityMessage $message = null,
        ?CommunityReport $report = null,
        ?CommunityIdentity $identity = null,
        array $metadata = [],
    ): void {
        CommunityModerationAudit::create([
            'action' => $action,
            'actor_user_id' => $request->user()->id,
            'community_message_id' => $message?->id,
            'community_report_id' => $report?->id,
            'community_identity_id' => $identity?->id,
            'metadata' => $metadata,
        ]);
    }
}
