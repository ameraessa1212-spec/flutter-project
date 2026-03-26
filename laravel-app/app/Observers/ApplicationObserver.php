<?php

namespace App\Observers;

use App\Models\Application;
use App\Models\InternshipOpportunity;

class ApplicationObserver
{
    public function updated(Application $application)
    {
        // Only act if status changed to approved
        if ($application->isDirty('status') && $application->status === 'approved') {
            $opportunity = $application->opportunity;
            if ($opportunity) {
                $approvedCount = $opportunity->applications()->where('status', 'approved')->count();
                if ($approvedCount >= $opportunity->seats_count && $opportunity->is_available) {
                    $opportunity->is_available = false;
                    $opportunity->save();
                }
            }

            // Send notification to student
            $student = $application->student;
            if ($student) {
                $student->notify(new \App\Notifications\TrainingAcceptedNotification(
                    $application->id,
                    $opportunity ? $opportunity->title : '',
                    $opportunity && $opportunity->company ? $opportunity->company->name : ''
                ));
            }
        }
    }
}
