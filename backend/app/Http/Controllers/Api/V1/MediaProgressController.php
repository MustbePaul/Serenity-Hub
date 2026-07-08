<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\MediaAsset;
use App\Models\UserMediaProgress;
use Illuminate\Http\Request;

class MediaProgressController extends ApiController
{
    public function store(Request $request, MediaAsset $media)
    {
        $data = $request->validate([
            'resource_id' => ['nullable', 'exists:resources,id'],
            'wellness_session_id' => ['nullable', 'exists:wellness_sessions,id'],
            'progress_seconds' => ['required', 'integer', 'min:0'],
            'duration_seconds' => ['required', 'integer', 'min:1'],
            'is_completed' => ['sometimes', 'boolean'],
        ]);

        $percent = min(100, round(($data['progress_seconds'] / $data['duration_seconds']) * 100, 2));
        $completed = (bool) ($data['is_completed'] ?? false) || $percent >= 95;

        $progress = UserMediaProgress::query()
            ->where('user_id', $request->user()->id)
            ->where('media_asset_id', $media->id)
            ->where('wellness_session_id', $data['wellness_session_id'] ?? null)
            ->first();

        $progress ??= new UserMediaProgress([
            'user_id' => $request->user()->id,
            'media_asset_id' => $media->id,
            'wellness_session_id' => $data['wellness_session_id'] ?? null,
        ]);

        $progress->fill([
            'resource_id' => $data['resource_id'] ?? $progress->resource_id,
            'progress_seconds' => $data['progress_seconds'],
            'duration_seconds' => $data['duration_seconds'],
            'progress_percent' => $percent,
            'is_completed' => $completed,
            'last_played_at' => now(),
            'completed_at' => $completed ? ($progress->completed_at ?? now()) : null,
        ])->save();

        return $this->success($progress->load(['mediaAsset', 'resource', 'wellnessSession']), 'Progress saved.', status: 201);
    }

    public function index(Request $request)
    {
        return $this->success(UserMediaProgress::query()
            ->where('user_id', $request->user()->id)
            ->with(['mediaAsset', 'resource.category', 'wellnessSession'])
            ->latest('last_played_at')
            ->get());
    }
}
