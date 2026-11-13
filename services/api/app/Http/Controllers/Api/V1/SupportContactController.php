<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\SupportContact;
use Illuminate\Http\Request;

class SupportContactController extends ApiController
{
    public function index(Request $request)
    {
        $data = $request->validate([
            'country_code' => ['nullable', 'string', 'size:2'],
            'is_emergency_service' => ['nullable', 'boolean'],
            'is_crisis_support' => ['nullable', 'boolean'],
        ]);

        $contacts = SupportContact::query()
            ->where('is_active', true)
            ->when($data['country_code'] ?? null, fn ($query, $country) => $query->where('country_code', strtoupper($country)))
            ->when($request->has('is_emergency_service'), fn ($query) => $query->where('is_emergency_service', $request->boolean('is_emergency_service')))
            ->when($request->has('is_crisis_support'), fn ($query) => $query->where('is_crisis_support', $request->boolean('is_crisis_support')))
            ->orderBy('display_order')
            ->orderBy('country_name')
            ->orderBy('service_name')
            ->get();

        return $this->success($contacts);
    }

    public function show(SupportContact $supportContact)
    {
        abort_unless($supportContact->is_active, 404);

        return $this->success($supportContact);
    }
}
