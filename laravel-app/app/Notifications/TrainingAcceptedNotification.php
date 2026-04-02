<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\BroadcastMessage;
use Illuminate\Notifications\Messages\DatabaseMessage;
use Illuminate\Notifications\Notification;

class TrainingAcceptedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public $applicationId;
    public $opportunityTitle;
    public $companyName;

    public function __construct($applicationId, $opportunityTitle, $companyName)
    {
        $this->applicationId = $applicationId;
        $this->opportunityTitle = $opportunityTitle;
        $this->companyName = $companyName;
    }

    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    public function toArray($notifiable)
    {
        return [
            'application_id' => $this->applicationId,
            'opportunity_title' => $this->opportunityTitle,
            'company_name' => $this->companyName,
            'message' => 'تم قبولك في فرصة التدريب لدى ' . $this->companyName . ' - ' . $this->opportunityTitle,
        ];
    }

    public function toDatabase($notifiable)
    {
        return $this->toArray($notifiable);
    }

    public function toBroadcast($notifiable)
    {
        return new BroadcastMessage($this->toArray($notifiable));
    }
}
