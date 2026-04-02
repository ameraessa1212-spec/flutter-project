<?php

namespace App\Observers;

use App\Models\UserNotification;
use App\Services\FirebaseNotificationService;

class UserNotificationObserver
{
    protected FirebaseNotificationService $firebase;

    public function __construct(FirebaseNotificationService $firebase)
    {
        $this->firebase = $firebase;
    }

    /**
     * Handle the UserNotification "created" event.
     */
    public function created(UserNotification $userNotification): void
    {
        if ($userNotification->user && $userNotification->user->fcm_token) {
            $this->firebase->sendToUser(
                $userNotification->user,
                $userNotification->title,
                $userNotification->body,
                [
                    'type' => $userNotification->type ?? 'general',
                    'reference_id' => (string) $userNotification->reference_id,
                    'reference_type' => (string) $userNotification->reference_type,
                    'notification_id' => (string) $userNotification->id,
                ]
            );
        }
    }

    /**
     * Handle the UserNotification "updated" event.
     */
    public function updated(UserNotification $userNotification): void
    {
        //
    }

    /**
     * Handle the UserNotification "deleted" event.
     */
    public function deleted(UserNotification $userNotification): void
    {
        //
    }

    /**
     * Handle the UserNotification "restored" event.
     */
    public function restored(UserNotification $userNotification): void
    {
        //
    }

    /**
     * Handle the UserNotification "force deleted" event.
     */
    public function forceDeleted(UserNotification $userNotification): void
    {
        //
    }
}
