<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\MediaAsset;
use Illuminate\Http\Request;

class MediaController extends ApiController
{
    public function index(Request $request)
    {
        $media = MediaAsset::query()
            ->with(['resources.category'])
            ->where('status', $request->query('status', 'published'))
            ->when($request->query('type'), fn ($query, $type) => $query->where('media_type', $type))
            ->when($request->query('query') ?? $request->query('q'), fn ($query, $term) => $query->where(fn ($inner) => $inner
                ->where('title', 'like', "%{$term}%")
                ->orWhere('description', 'like', "%{$term}%")
                ->orWhere('transcript', 'like', "%{$term}%")))
            ->when($request->query('category'), fn ($query, $category) => $query->whereHas('resources.category', fn ($inner) => $inner->where('slug', $category)))
            ->latest()
            ->paginate($request->integer('per_page', 20));

        return $this->success($media->items(), meta: [
            'current_page' => $media->currentPage(),
            'last_page' => $media->lastPage(),
            'total' => $media->total(),
        ]);
    }

    public function show(MediaAsset $media)
    {
        abort_unless($media->status === 'published', 404);

        return $this->success($media->load(['resources.category']));
    }
}
