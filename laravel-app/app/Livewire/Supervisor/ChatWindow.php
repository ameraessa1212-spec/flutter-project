<?php

namespace App\Livewire\Supervisor;

use App\Events\MessageSent;
use App\Models\ChatThread;
use Throwable;
use Livewire\Component;

class ChatWindow extends Component
{
    public ?ChatThread $activeThread = null;
    public string $newMessageBody = '';

    public function getListeners()
    {
        if ($this->activeThread) {
            return [
                "echo-private:chat.{$this->activeThread->id},.message.sent" => 'refreshMessages',
                'threadSelected' => 'threadSelected',
            ];
        }
        
        return ['threadSelected' => 'threadSelected'];
    }

    public function threadSelected($threadId)
    {
        $this->activeThread = ChatThread::with(['student', 'internship.company'])->find($threadId);
        $this->markAsRead();
        $this->dispatch('chat-window-updated');
    }

    public function refreshMessages()
    {
        $this->markAsRead();
        $this->dispatch('chat-window-updated');
    }

    public function markAsRead()
    {
        if ($this->activeThread) {
            $this->activeThread->messages()
                ->where('sender_id', '!=', auth()->id())
                ->whereNull('read_at')
                ->update(['read_at' => now()]);
                
            $this->dispatch('messageReceived');
        }
    }

    public function sendMessage()
    {
        $body = trim($this->newMessageBody);
        
        if (empty($body) || !$this->activeThread) {
            return;
        }

        $message = $this->activeThread->messages()->create([
            'sender_id' => auth()->id(),
            'message_type' => 'text',
            'body' => $body,
            'sent_at' => now(),
        ]);

        $this->activeThread->update([
            'last_message_at' => now(),
        ]);

        $this->newMessageBody = '';

        try {
            broadcast(new MessageSent($message))->toOthers();
        } catch (Throwable $exception) {
            report($exception);
        }

        $this->dispatch('messageReceived');
        $this->dispatch('chat-window-updated');
    }

    public function render()
    {
        $messages = [];
        
        if ($this->activeThread) {
            $messages = $this->activeThread->messages()->oldest()->get();
        }

        return view('livewire.supervisor.chat-window', [
            'messages' => $messages,
        ]);
    }
}
