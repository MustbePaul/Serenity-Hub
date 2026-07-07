<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Appointment;
use App\Models\AvailabilitySlot;
use App\Models\Bookmark;
use App\Models\MoodCheckin;
use App\Models\QuoteAffirmation;
use App\Models\Resource;
use App\Models\ResourceCategory;
use App\Models\SupportTicket;
use App\Models\TherapistProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AppContentController extends ApiController
{
    public function home(Request $request)
    {
        return $this->success([
            'quote' => QuoteAffirmation::query()->where('active', true)->latest('display_date')->first(),
            'affirmation' => QuoteAffirmation::query()->where('active', true)->where('type', 'affirmation')->inRandomOrder()->first(),
            'recommended_resource' => Resource::query()->where('status', 'published')->with('category')->inRandomOrder()->first(),
            'upcoming_appointment' => Appointment::query()
                ->where('user_id', $request->user()?->id)
                ->whereIn('status', ['pending', 'confirmed'])
                ->orderBy('scheduled_start')
                ->first(),
        ]);
    }

    public function categories()
    {
        return $this->success(ResourceCategory::query()->orderBy('display_order')->get());
    }

    public function resources(Request $request)
    {
        $resources = Resource::query()
            ->with('category')
            ->where('status', 'published')
            ->when($request->query('q'), fn ($query, $q) => $query->where(fn ($inner) => $inner
                ->where('title', 'like', "%{$q}%")
                ->orWhere('summary', 'like', "%{$q}%")))
            ->when($request->query('category'), fn ($query, $slug) => $query->whereHas('category', fn ($inner) => $inner->where('slug', $slug)))
            ->latest('published_at')
            ->paginate($request->integer('per_page', 15));

        return $this->success($resources->items(), meta: [
            'current_page' => $resources->currentPage(),
            'last_page' => $resources->lastPage(),
            'total' => $resources->total(),
        ]);
    }

    public function resource(Resource $resource)
    {
        abort_unless($resource->status === 'published', 404);

        return $this->success($resource->load('category'));
    }

    public function bookmark(Request $request, Resource $resource)
    {
        Bookmark::firstOrCreate([
            'user_id' => $request->user()->id,
            'resource_id' => $resource->id,
        ]);

        return $this->success(null, 'Resource bookmarked.');
    }

    public function removeBookmark(Request $request, Resource $resource)
    {
        Bookmark::where('user_id', $request->user()->id)->where('resource_id', $resource->id)->delete();

        return $this->success(null, 'Bookmark removed.');
    }

    public function bookmarks(Request $request)
    {
        return $this->success(Bookmark::query()
            ->where('user_id', $request->user()->id)
            ->with('resource.category')
            ->latest()
            ->get());
    }

    public function therapists(Request $request)
    {
        $therapists = TherapistProfile::query()
            ->with(['user:id,name,email', 'specialties'])
            ->where('verification_status', 'approved')
            ->when($request->query('q'), fn ($query, $q) => $query->whereHas('user', fn ($inner) => $inner->where('name', 'like', "%{$q}%")))
            ->when($request->query('location'), fn ($query, $location) => $query->where('location', 'like', "%{$location}%"))
            ->get();

        return $this->success($therapists);
    }

    public function availability(TherapistProfile $therapist)
    {
        abort_unless($therapist->verification_status === 'approved', 404);

        return $this->success($therapist->availabilitySlots()->where('status', 'available')->orderBy('starts_at')->get());
    }

    public function book(Request $request)
    {
        $data = $request->validate([
            'therapist_id' => ['required', 'exists:therapist_profiles,id'],
            'availability_slot_id' => ['required', 'exists:availability_slots,id'],
            'mode' => ['required', 'in:online,phone,in_person'],
            'reason' => ['nullable', 'string', 'max:1000'],
        ]);

        $appointment = DB::transaction(function () use ($request, $data) {
            $slot = AvailabilitySlot::whereKey($data['availability_slot_id'])->lockForUpdate()->firstOrFail();

            if ($slot->status !== 'available' || (int) $slot->therapist_id !== (int) $data['therapist_id']) {
                abort(409, 'This time slot is no longer available.');
            }

            $slot->update(['status' => 'booked']);

            return Appointment::create([
                'user_id' => $request->user()->id,
                'therapist_id' => $data['therapist_id'],
                'availability_slot_id' => $slot->id,
                'scheduled_start' => $slot->starts_at,
                'scheduled_end' => $slot->ends_at,
                'mode' => $data['mode'],
                'reason' => $data['reason'] ?? null,
                'status' => 'confirmed',
            ]);
        });

        return $this->success($appointment, 'Appointment booked successfully.', status: 201);
    }

    public function mood(Request $request)
    {
        $data = $request->validate([
            'mood_score' => ['required', 'integer', 'between:1,5'],
            'tags' => ['nullable', 'array'],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $checkin = MoodCheckin::create([
            ...$data,
            'user_id' => $request->user()->id,
            'checked_in_at' => now(),
        ]);

        return $this->success($checkin, 'Mood check-in saved.', status: 201);
    }

    public function support(Request $request)
    {
        $data = $request->validate([
            'subject' => ['required', 'string', 'max:255'],
            'message' => ['required', 'string', 'min:10'],
            'priority' => ['nullable', 'in:low,normal,urgent'],
        ]);

        $ticket = SupportTicket::create([
            ...$data,
            'priority' => $data['priority'] ?? 'normal',
            'user_id' => $request->user()?->id,
        ]);

        return $this->success($ticket, 'Support ticket created.', status: 201);
    }
}
