<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Appointment;
use App\Models\AvailabilitySlot;
use App\Models\TherapistProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AppointmentController extends ApiController
{
    private const ACTIVE_STATUSES = ['pending', 'confirmed', 'rescheduled'];

    public function show(Request $request, Appointment $appointment)
    {
        abort_unless((int) $appointment->user_id === (int) $request->user()->id, 404);

        return $this->success($appointment->load(['therapist.user:id,name,email', 'availabilitySlot']));
    }

    public function cancel(Request $request, Appointment $appointment)
    {
        abort_unless((int) $appointment->user_id === (int) $request->user()->id, 404);

        $data = $request->validate([
            'reason' => ['nullable', 'string', 'max:1000'],
        ]);

        if (! in_array($appointment->status, self::ACTIVE_STATUSES, true)) {
            abort(422, 'This appointment cannot be cancelled.');
        }

        $updated = DB::transaction(function () use ($appointment, $data) {
            $appointment->load('availabilitySlot');
            $appointment->update([
                'status' => 'cancelled',
                'reason' => $data['reason'] ?? $appointment->reason,
            ]);

            if ($appointment->availabilitySlot && $appointment->scheduled_start->isFuture()) {
                $appointment->availabilitySlot->update(['status' => 'available']);
            }

            return $appointment->refresh()->load(['therapist.user:id,name,email', 'availabilitySlot']);
        });

        return $this->success($updated, 'Appointment cancelled.');
    }

    public function reschedule(Request $request, Appointment $appointment)
    {
        abort_unless((int) $appointment->user_id === (int) $request->user()->id, 404);

        $data = $request->validate([
            'availability_slot_id' => ['required', 'exists:availability_slots,id'],
        ]);

        if (! in_array($appointment->status, self::ACTIVE_STATUSES, true)) {
            abort(422, 'This appointment cannot be rescheduled.');
        }

        $updated = DB::transaction(function () use ($appointment, $data) {
            $appointment->load('availabilitySlot');
            $therapist = TherapistProfile::whereKey($appointment->therapist_id)
                ->where('verification_status', 'approved')
                ->firstOrFail();
            $slot = AvailabilitySlot::whereKey($data['availability_slot_id'])->lockForUpdate()->firstOrFail();

            if ($slot->status !== 'available' || (int) $slot->therapist_id !== (int) $therapist->id || $slot->starts_at->isPast()) {
                abort(409, 'This time slot is no longer available.');
            }

            $hasOverlap = Appointment::query()
                ->whereKeyNot($appointment->id)
                ->where('therapist_id', $therapist->id)
                ->whereIn('status', self::ACTIVE_STATUSES)
                ->where('scheduled_start', '<', $slot->ends_at)
                ->where('scheduled_end', '>', $slot->starts_at)
                ->exists();

            if ($hasOverlap) {
                abort(409, 'This time slot is no longer available.');
            }

            if ($appointment->availabilitySlot && $appointment->availabilitySlot->id !== $slot->id) {
                $appointment->availabilitySlot->update(['status' => 'available']);
            }

            $slot->update(['status' => 'booked']);
            $appointment->update([
                'availability_slot_id' => $slot->id,
                'scheduled_start' => $slot->starts_at,
                'scheduled_end' => $slot->ends_at,
                'status' => 'rescheduled',
            ]);

            return $appointment->refresh()->load(['therapist.user:id,name,email', 'availabilitySlot']);
        });

        return $this->success($updated, 'Appointment rescheduled.');
    }
}
