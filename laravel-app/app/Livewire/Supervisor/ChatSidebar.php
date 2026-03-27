<?php

namespace App\Livewire\Supervisor;

use App\Models\ChatThread;
use Livewire\Component;
use Livewire\Attributes\On;

class ChatSidebar extends Component
{
    public $activeThreadId = null;

    public $search = '';

    #[On('threadSelected')]
    public function selectThread($threadId)
    {
        $this->activeThreadId = $threadId;
    }

    #[On('messageReceived')]
    public function render()
    {
        $user = auth()->user();
        $query = ChatThread::query()->with(['student', 'internship.company', 'messages' => function($q) {
            $q->latest()->limit(1);
        }]);

        if (!$user->hasRole('super_admin') && $user->hasRole('supervisor') && $user->supervisorProfile) {
            $query->where('supervisor_id', $user->supervisorProfile->id);
        }

        if (!empty($this->search)) {
            $query->whereHas('student', function ($q) {
                $q->where('name', 'like', '%' . $this->search . '%');
            })->orWhereHas('internship.company', function ($q) {
                $q->where('name', 'like', '%' . $this->search . '%');
            });
        }

        $threads = $query->orderBy('last_message_at', 'desc')->get();

        return view('livewire.supervisor.chat-sidebar', [
            'threads' => $threads,
        ]);
    }
}
