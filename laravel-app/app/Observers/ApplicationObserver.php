<?php

namespace App\Observers;

use App\Models\Application;
use App\Models\InternshipOpportunity;

class ApplicationObserver
{
    protected $firebase;

    public function __construct(\App\Services\FirebaseService $firebase)
    {
        $this->firebase = $firebase;
    }

    public function updated(Application $application)
    {
        // Only act if status changed to approved or accepted
        if ($application->isDirty('status') && in_array($application->status, ['approved', 'accepted'])) {
            $opportunity = $application->opportunity;
            if ($opportunity) {
                $approvedCount = $opportunity->applications()
                    ->whereIn('status', ['approved', 'accepted'])
                    ->count();
                if ($approvedCount >= $opportunity->seats_count && $opportunity->is_available) {
                    $opportunity->is_available = false;
                    $opportunity->save();
                }
            }

            // Send database notification (existing)
            $student = $application->student;
            if ($student) {
                $student->notify(new \App\Notifications\TrainingAcceptedNotification(
                    $application->id,
                    $opportunity ? $opportunity->title : '',
                    $opportunity && $opportunity->company ? $opportunity->company->name : ''
                ));

                // Send real FCM notification via FirebaseService
                $this->firebase->notifyUser(
                    $student,
                    'تهانينا! تم قبول طلبك',
                    'تم قبولك في فرصة التدريب لدى ' . ($opportunity->company->name ?? 'الشركة') . ' - ' . ($opportunity->title ?? ''),
                    [
                        'type' => 'application_accepted',
                        'application_id' => (string) $application->id,
                    ]
                );
            }
        }
    }
}


