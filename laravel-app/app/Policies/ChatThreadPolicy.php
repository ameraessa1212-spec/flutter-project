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

        // Admin/support can view all threads
        if ($user->hasRole('super_admin') || $user->hasRole('support')) {
            return true;
        }

        return false;
    }
}
