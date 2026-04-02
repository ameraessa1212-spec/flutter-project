<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FirebaseNotificationService
{
    protected Messaging $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    public function sendToUser(User $user, string $title, string $body, array $data = []): bool
    {
        if (empty($user->fcm_token)) {
            return false;
        }

        try {
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::withTarget('token', $user->fcm_token)
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->send($message);
            
            return true;
        } catch (\Exception $e) {
            Log::error('FCM Notification Error: ' . $e->getMessage(), [
                'user_id' => $user->id,
            ]);
            return false;
        }
    }
}
