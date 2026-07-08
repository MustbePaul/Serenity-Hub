<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\WellnessSession;
use Illuminate\Http\Request;

class WellnessSessionController extends ApiController
{
    public function index(Request $request)
    {
        $sessions = WellnessSession::query()
            ->with(['mediaAsset', 'resource.category'])
            ->where('status', 'published')
            ->when($request->query('category'), fn ($query, $category) => $query->where('category', $category))
            ->when($request->query('mood'), fn ($query, $mood) => $query->where('target_mood', $mood))
            ->when($request->has('featured'), fn ($query) => $query->where('is_featured', $request->boolean('featured')))
            ->orderByDesc('is_featured')
            ->latest()
            ->paginate($request->integer('per_page', 20));

        return $this->success($sessions->items(), meta: [
            'current_page' => $sessions->currentPage(),
            'last_page' => $sessions->lastPage(),
            'total' => $sessions->total(),
        ]);
    }

    public function show(WellnessSession $session)
    {
        abort_unless($session->status === 'published', 404);

        return $this->success($session->load(['mediaAsset', 'resource.category']));
    }
}
