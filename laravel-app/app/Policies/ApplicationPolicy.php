<?php

namespace App\Policies;

use App\Models\Application;
use App\Models\User;

class ApplicationPolicy
{
    public function view(User $user, Application $application): bool
    {
        return $application->student_id === $user->id;
    }

    public function delete(User $user, Application $application): bool
    {
        return $application->student_id === $user->id
            && in_array($application->status, ['pending', 'under_review'], true);
    }
}
