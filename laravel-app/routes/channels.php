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

    // Check if user is the student involved
    if ($thread->student_id === $user->id) {
        return true;
    }

    // Check if user is the supervisor attached to the thread
    if ($user->hasRole('supervisor') && $user->supervisorProfile && $thread->supervisor_id === $user->supervisorProfile->id) {
        return true;
    }

    // Admins and support can view all channels (especially support threads)
    if ($user->hasRole('super_admin') || $user->hasRole('support')) {
        return true;
    }

    // Supervisors can see support threads (no supervisor assigned)
    if ($user->hasRole('supervisor') && $thread->supervisor_id === null) {
        return true;
    }

    return false;
});
