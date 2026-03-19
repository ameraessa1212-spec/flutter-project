<?php

namespace App\Policies;

use App\Models\Report;
use App\Models\User;

class ReportPolicy
{
    public function view(User $user, Report $report): bool
    {
        return $report->student_id === $user->id;
    }

    public function delete(User $user, Report $report): bool
    {
        return $report->student_id === $user->id
            && in_array($report->status, ['draft', 'submitted'], true);
    }
}
