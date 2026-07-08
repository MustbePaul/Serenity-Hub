<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\MediaAsset;
use App\Models\MoodCheckin;
use App\Models\WellnessSession;
use Illuminate\Http\Request;

class RecommendationController extends ApiController
{
    private const MOOD_CATEGORIES = [
        'anxious' => ['anxiety', 'breathing', 'grounding'],
        'stressed' => ['stress', 'breathing', 'sleep'],
        'sad' => ['encouragement', 'reflection', 'therapist-support'],
        'angry' => ['grounding', 'breathing'],
        'tired' => ['sleep', 'rest', 'reflection'],
        'calm' => ['mindfulness', 'gratitude', 'daily-growth'],
    ];

    public function index(Request $request)
    {
        $mood = MoodCheckin::query()
            ->where('user_id', $request->user()->id)
            ->latest('checked_in_at')
            ->first();

        $moodKey = $mood ? $this->moodKey($mood) : null;
        $categories = $moodKey ? self::MOOD_CATEGORIES[$moodKey] : [];

        $sessionsQuery = WellnessSession::query()
            ->with(['mediaAsset', 'resource.category'])
            ->where('status', 'published');

        if ($categories !== []) {
            $sessionsQuery->whereIn('category', $categories);
        } else {
            $sessionsQuery->where('is_featured', true);
        }

        $sessions = $sessionsQuery
            ->withExists(['mediaAsset as user_completed' => fn ($query) => $query->whereHas('progress', fn ($inner) => $inner
                ->where('user_id', $request->user()->id)
                ->where('is_completed', true))])
            ->orderBy('user_completed')
            ->orderByDesc('is_featured')
            ->limit(6)
            ->get();

        $media = MediaAsset::query()
            ->with(['resources.category'])
            ->where('status', 'published')
            ->when($categories !== [], fn ($query) => $query->whereHas('resources.category', fn ($inner) => $inner->whereIn('slug', $categories)))
            ->limit(4)
            ->get();

        return $this->success([
            'latest_mood' => $mood,
            'mood_key' => $moodKey,
            'categories' => $categories,
            'sessions' => $sessions,
            'media' => $media,
            'headline' => $moodKey ? 'Recommended for feeling '.$moodKey : 'Featured serenity sessions',
        ]);
    }

    private function moodKey(MoodCheckin $mood): string
    {
        $haystack = strtolower(implode(' ', [
            implode(' ', $mood->tags ?? []),
            $mood->note ?? '',
        ]));

        foreach (array_keys(self::MOOD_CATEGORIES) as $key) {
            if (str_contains($haystack, $key)) {
                return $key;
            }
        }

        return match (true) {
            $mood->mood_score <= 1 => 'sad',
            $mood->mood_score === 2 => 'stressed',
            $mood->mood_score === 3 => 'tired',
            default => 'calm',
        };
    }
}
