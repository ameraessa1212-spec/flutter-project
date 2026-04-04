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
    public function refreshThreads(): void
    {
    }

    public function render()
    {
        $user = auth()->user();
        $query = ChatThread::query()
            ->with([
                'student',
                'internship.company',
                'messages' => function ($query) {
                    $query->latest()->limit(1);
                },
            ])
            ->withCount([
                'messages as unread_messages_count' => function ($query) {
                    $query->where('sender_id', '!=', auth()->id())
                        ->whereNull('read_at');
                },
            ]);

        if (!$user->hasRole('super_admin') && $user->hasRole('supervisor') && $user->supervisorProfile) {
            $query->where(function ($q) use ($user) {
                $q->where('supervisor_id', $user->supervisorProfile->id)
                    ->orWhereNull('supervisor_id');
            });
        }

        if (!empty($this->search)) {
            $query->where(function ($query) {
                $query->whereHas('student', function ($studentQuery) {
                    $studentQuery->where('name', 'like', '%' . $this->search . '%');
                })->orWhereHas('internship.company', function ($companyQuery) {
                    $companyQuery->where('name', 'like', '%' . $this->search . '%');
                });
            });
        }

        $threads = $query->orderBy('last_message_at', 'desc')->get();

        return view('livewire.supervisor.chat-sidebar', [
            'threads' => $threads,
        ]);
    }
}
