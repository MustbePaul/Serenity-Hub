<?php

namespace App\Events;

use App\Models\CommunityMessage;
use App\Support\CommunityMessagePayload;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CommunityMessageCreated implements ShouldBroadcast
{
    use Dispatchable, SerializesModels;

    public function __construct(public CommunityMessage $message)
    {
        $this->message->loadMissing(['identity', 'room']);
    }

    public function broadcastOn(): PrivateChannel
    {
        return new PrivateChannel('community.room.'.$this->message->room->slug);
    }

    public function broadcastAs(): string
    {
        return 'CommunityMessageCreated';
    }

    public function broadcastWith(): array
    {
        return [
            'message' => CommunityMessagePayload::forBroadcast($this->message),
            'room' => ['slug' => $this->message->room->slug],
        ];
    }
}
