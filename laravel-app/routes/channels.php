<?php

use App\Models\ChatThread;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('chat.{threadId}', function ($user, $threadId) {
    $thread = ChatThread::find($threadId);
    if (!$thread) {
        return false;
    }
    return $thread->participant_1_id === $user->id || $thread->participant_2_id === $user->id;
});
