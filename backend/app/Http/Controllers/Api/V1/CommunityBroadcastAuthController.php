<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\CommunityRoom;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Pusher\Pusher;

class CommunityBroadcastAuthController extends ApiController
{
    public function __invoke(Request $request)
    {
        $data = $request->validate([
            'socket_id' => ['required', 'string', 'max:100'],
            'channel_name' => ['required', 'string', 'max:150'],
        ]);

        $prefix = 'private-community.room.';
        abort_unless(Str::startsWith($data['channel_name'], $prefix), 403);

        $slug = Str::after($data['channel_name'], $prefix);
        abort_unless(CommunityRoom::query()->where('slug', $slug)->where('is_active', true)->exists(), 403);

        $pusher = new Pusher(
            config('broadcasting.connections.reverb.key'),
            config('broadcasting.connections.reverb.secret'),
            config('broadcasting.connections.reverb.app_id'),
            config('broadcasting.connections.reverb.options', []),
        );

        return response()->json(json_decode($pusher->socket_auth($data['channel_name'], $data['socket_id']), true));
    }
}
