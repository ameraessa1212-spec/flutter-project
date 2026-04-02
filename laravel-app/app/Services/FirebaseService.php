<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Contract\Messaging;
use Illuminate\Support\Facades\Log;

class FirebaseService
{
    protected Messaging $messaging;

    public function __construct()
    {
        $factory = (new Factory)
            ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS', 'storage/app/firebase/service-account.json')));
        
        if ($databaseUrl = env('FIREBASE_DATABASE_URL')) {
            $factory = $factory->withDatabaseUri($databaseUrl);
        }

        $this->messaging = $factory->createMessaging();
    }

    /**
     * Send a notification to a specific FCM token
     */
    public function sendNotification(string $token, string $title, string $body, array $data = [])
    {
        try {
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $this->messaging->send($message);
            return true;
        } catch (\Exception $e) {
            Log::error('Firebase Notification Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send a notification to a specific user using their FCM token
     */
    public function notifyUser($user, string $title, string $body, array $data = [])
    {
        if ($user->fcm_token) {
            return $this->sendNotification($user->fcm_token, $title, $body, $data);
        }
        return false;
    }
}
