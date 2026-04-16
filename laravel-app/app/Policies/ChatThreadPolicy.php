<?php

namespace App\Policies;

use App\Models\ChatThread;
use App\Models\User;

class ChatThreadPolicy
{
    public function view(User $user, ChatThread $thread): bool
    {
        // Student can view their own threads
        if ($thread->student_id === $user->id) {
            return true;
        }

        // Supervisor can view threads assigned to them
        if ($user->hasRole('supervisor') && $user->supervisorProfile
            && $thread->supervisor_id === $user->supervisorProfile->id) {
            return true;
        }

        // All admin roles except examiner share the chat with students
        if (in_array($user->role, ['super_admin', 'operations', 'content_manager', 'support'], true)) {
            return true;
        }

        return false;
    }
}
