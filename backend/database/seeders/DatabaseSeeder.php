<?php

namespace Database\Seeders;

use App\Models\AvailabilitySlot;
use App\Models\MediaAsset;
use App\Models\QuoteAffirmation;
use App\Models\Resource;
use App\Models\ResourceCategory;
use App\Models\Specialty;
use App\Models\TherapistProfile;
use App\Models\User;
use App\Models\WellnessSession;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::firstOrCreate(
            ['email' => 'admin@serenityhub.test'],
            [
                'name' => 'Serenity Admin',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'status' => 'active',
            ],
        );

        $user = User::firstOrCreate(
            ['email' => 'user@serenityhub.test'],
            [
                'name' => 'Test User',
                'password' => Hash::make('password'),
                'role' => 'user',
                'status' => 'active',
            ],
        );
        $user->profile()->firstOrCreate(['user_id' => $user->id], ['privacy_consent_at' => now()]);
        $user->settings()->firstOrCreate(['user_id' => $user->id]);

        $categories = collect([
            ['name' => 'Stress', 'slug' => 'stress', 'description' => 'Grounding and coping strategies for stressful moments.', 'display_order' => 1],
            ['name' => 'Anxiety', 'slug' => 'anxiety', 'description' => 'Gentle education and practical calming exercises.', 'display_order' => 2],
            ['name' => 'Sleep', 'slug' => 'sleep', 'description' => 'Rest routines, sleep hygiene, and wind-down support.', 'display_order' => 3],
            ['name' => 'Self-care', 'slug' => 'self-care', 'description' => 'Small practices that support everyday wellbeing.', 'display_order' => 4],
        ])->map(fn ($category) => ResourceCategory::firstOrCreate(['slug' => $category['slug']], $category));

        foreach ([
            ['category' => 'stress', 'title' => 'A 5-minute reset for a busy mind', 'slug' => 'five-minute-reset', 'summary' => 'A short grounding routine using breath, posture, and attention.', 'tags' => ['stress', 'grounding']],
            ['category' => 'anxiety', 'title' => 'Understanding anxiety signals', 'slug' => 'understanding-anxiety-signals', 'summary' => 'Learn common body and thought patterns that can show up with anxiety.', 'tags' => ['anxiety', 'education']],
            ['category' => 'sleep', 'title' => 'Building a softer evening routine', 'slug' => 'softer-evening-routine', 'summary' => 'Practical steps for reducing stimulation and preparing for rest.', 'tags' => ['sleep', 'routine']],
            ['category' => 'self-care', 'title' => 'Choosing one kind thing today', 'slug' => 'one-kind-thing-today', 'summary' => 'A simple prompt for caring for yourself without turning it into a chore.', 'tags' => ['self-care', 'reflection']],
        ] as $resource) {
            $category = $categories->firstWhere('slug', $resource['category']);
            Resource::firstOrCreate(
                ['slug' => $resource['slug']],
                [
                    'category_id' => $category->id,
                    'title' => $resource['title'],
                    'type' => 'article',
                    'summary' => $resource['summary'],
                    'body' => $resource['summary']."\n\nPause, notice what is present, and choose the smallest next step that supports your wellbeing. Serenity Hub offers wellness support and access to professional care, not emergency treatment or diagnosis.",
                    'tags' => $resource['tags'],
                    'status' => 'published',
                    'published_at' => now(),
                    'created_by' => $admin->id,
                ],
            );
        }

        foreach ([
            ['text' => 'You do not have to solve the whole day at once.', 'author' => 'Serenity Hub', 'theme' => 'grounding', 'type' => 'quote'],
            ['text' => 'I can take one steady breath and begin again.', 'author' => null, 'theme' => 'calm', 'type' => 'affirmation'],
        ] as $quote) {
            QuoteAffirmation::firstOrCreate(['text' => $quote['text']], [...$quote, 'active' => true, 'display_date' => now()->toDateString(), 'created_by' => $admin->id]);
        }

        MediaAsset::query()
            ->where('file_url', 'like', 'https://example.com/serenity/%')
            ->delete();

        $mediaAssets = collect([
            [
                'title' => 'Namaste calming audio',
                'media_type' => 'audio',
                'file_url' => 'https://audionautix.com/Music/Namaste.mp3',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=960&q=80',
                'duration_seconds' => 245,
                'category' => 'stress',
                'description' => 'A slow meditative music track for breathing, grounding, and quiet focus.',
                'transcript' => 'Instrumental meditative music by Jason Shaw/AudionautiX. Try pairing the track with slow breathing and relaxed shoulders.',
            ],
            [
                'title' => 'Navajo Night long rest audio',
                'media_type' => 'audio',
                'file_url' => 'https://audionautix.com/Music/NavajoNight.mp3',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=960&q=80',
                'duration_seconds' => 1440,
                'category' => 'sleep',
                'description' => 'A longer meditative music track suited to rest, sleep preparation, or reflection.',
                'transcript' => 'Instrumental meditative music by Jason Shaw/AudionautiX. Let the track support a slower evening rhythm.',
            ],
            [
                'title' => 'Ohm grounding audio',
                'media_type' => 'audio',
                'file_url' => 'https://audionautix.com/Music/Ohm.mp3',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=960&q=80',
                'duration_seconds' => 369,
                'category' => 'anxiety',
                'description' => 'A spacious meditative track for anxious moments and sensory grounding.',
                'transcript' => 'Instrumental meditative music by Jason Shaw/AudionautiX. Notice your breath, your seat, and the sounds around you.',
            ],
            [
                'title' => 'Flower focus video',
                'media_type' => 'video',
                'file_url' => 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=960&q=80',
                'duration_seconds' => 5,
                'category' => 'self-care',
                'description' => 'A short visual pause for mindful attention and gentle reset.',
                'transcript' => 'Watch the motion and color for a few breaths. Let your attention rest on one simple visual detail.',
            ],
            [
                'title' => 'Sintel visual pause',
                'media_type' => 'video',
                'file_url' => 'https://media.w3.org/2010/05/sintel/trailer.mp4',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1518391846015-55a9cc003b25?auto=format&fit=crop&w=960&q=80',
                'duration_seconds' => 52,
                'category' => 'stress',
                'description' => 'A brief public demo video used here to exercise video playback and progress tracking.',
                'transcript' => 'Use this video as a short visual pause. If the imagery feels activating, stop and choose an audio session instead.',
            ],
        ])->map(function ($media, $index) use ($admin, $categories) {
            $asset = MediaAsset::updateOrCreate(
                ['title' => $media['title']],
                [
                    'description' => $media['description'],
                    'media_type' => $media['media_type'],
                    'file_url' => $media['file_url'],
                    'thumbnail_url' => $media['thumbnail_url'],
                    'duration_seconds' => $media['duration_seconds'],
                    'language' => 'en',
                    'transcript' => $media['transcript'],
                    'status' => 'published',
                    'created_by' => $admin->id,
                ],
            );

            $resource = Resource::where('category_id', $categories->firstWhere('slug', $media['category'])?->id)->first();
            if ($resource) {
                $asset->resources()->syncWithoutDetaching([$resource->id => ['sort_order' => $index]]);
            }

            return $asset;
        });

        foreach ([
            ['title' => 'Breathe and Begin Again', 'category' => 'breathing', 'target_mood' => 'anxious', 'media' => 'Namaste calming audio', 'featured' => true],
            ['title' => 'Name the Room', 'category' => 'grounding', 'target_mood' => 'anxious', 'media' => 'Ohm grounding audio', 'featured' => true],
            ['title' => 'Visual Reset', 'category' => 'stress', 'target_mood' => 'stressed', 'media' => 'Sintel visual pause', 'featured' => false],
            ['title' => 'Rest Permission', 'category' => 'sleep', 'target_mood' => 'tired', 'media' => 'Navajo Night long rest audio', 'featured' => true],
            ['title' => 'One Good Thing', 'category' => 'gratitude', 'target_mood' => 'calm', 'media' => 'Flower focus video', 'featured' => false],
        ] as $sessionSeed) {
            $asset = $mediaAssets->firstWhere('title', $sessionSeed['media']);
            WellnessSession::updateOrCreate(
                ['title' => $sessionSeed['title']],
                [
                    'description' => $asset?->description,
                    'category' => $sessionSeed['category'],
                    'target_mood' => $sessionSeed['target_mood'],
                    'difficulty' => 'beginner',
                    'estimated_duration_seconds' => $asset?->duration_seconds,
                    'resource_id' => $asset?->resources()->first()?->id,
                    'media_asset_id' => $asset->id,
                    'is_featured' => $sessionSeed['featured'],
                    'status' => 'published',
                ],
            );
        }

        $specialties = collect([
            ['name' => 'Anxiety and Stress', 'slug' => 'anxiety-stress'],
            ['name' => 'Depression Support', 'slug' => 'depression-support'],
            ['name' => 'Relationship Counselling', 'slug' => 'relationship-counselling'],
        ])->map(fn ($specialty) => Specialty::firstOrCreate(['slug' => $specialty['slug']], $specialty));

        foreach ([
            ['name' => 'Dr. A. Banda', 'email' => 'banda@serenityhub.test', 'license' => 'SH-THER-001', 'location' => 'Lilongwe', 'fee' => 15000],
            ['name' => 'Thandiwe Phiri', 'email' => 'phiri@serenityhub.test', 'license' => 'SH-THER-002', 'location' => 'Blantyre', 'fee' => 12000],
        ] as $therapistSeed) {
            $therapistUser = User::firstOrCreate(
                ['email' => $therapistSeed['email']],
                [
                    'name' => $therapistSeed['name'],
                    'password' => Hash::make('password'),
                    'role' => 'therapist',
                    'status' => 'active',
                ],
            );
            $therapist = TherapistProfile::firstOrCreate(
                ['license_number' => $therapistSeed['license']],
                [
                    'user_id' => $therapistUser->id,
                    'qualifications' => 'Licensed mental health professional',
                    'bio' => 'Provides calm, practical support for everyday mental wellness and guided professional care.',
                    'location' => $therapistSeed['location'],
                    'consultation_fee' => $therapistSeed['fee'],
                    'session_modes' => ['online', 'phone', 'in_person'],
                    'verification_status' => 'approved',
                    'verified_at' => now(),
                ],
            );
            $therapist->specialties()->syncWithoutDetaching($specialties->pluck('id')->take(2)->all());
            for ($i = 1; $i <= 3; $i++) {
                AvailabilitySlot::firstOrCreate([
                    'therapist_id' => $therapist->id,
                    'starts_at' => now()->addDays($i)->setTime(9 + $i, 0),
                ], [
                    'ends_at' => now()->addDays($i)->setTime(10 + $i, 0),
                    'status' => 'available',
                    'timezone' => 'Africa/Blantyre',
                    'created_by' => $admin->id,
                ]);
            }
        }
    }
}
