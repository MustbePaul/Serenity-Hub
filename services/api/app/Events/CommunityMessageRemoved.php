<?php

namespace App\Events;

use App\Models\CommunityMessage;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CommunityMessageRemoved implements ShouldBroadcast
{
    use Dispatchable, SerializesModels;

    public function __construct(public CommunityMessage $message)
    {
        $this->message->loadMissing('room');
    }

    public function broadcastOn(): PrivateChannel
    {
        return new PrivateChannel('community.room.'.$this->message->room->slug);
    }

    public function broadcastAs(): string
    {
        return 'CommunityMessageRemoved';
    }

    public function broadcastWith(): array
    {
        return [
            'message_id' => $this->message->id,
            'parent_id' => $this->message->parent_id,
            'status' => $this->message->status,
            'room' => ['slug' => $this->message->room->slug],
        ];
    }
}
