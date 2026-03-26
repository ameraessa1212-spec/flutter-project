<?php

namespace App\Livewire\Supervisor;

use App\Events\MessageSent;
use App\Models\ChatThread;
use App\Models\Message;
use Livewire\Component;
use Livewire\Attributes\On;

class ChatWindow extends Component
{
    public ?ChatThread $activeThread = null;
    public string $newMessageBody = '';

    public function getListeners()
    {
        if ($this->activeThread) {
            return [
                "echo-private:chat.{$this->activeThread->id},MessageSent" => 'refreshMessages',
                'threadSelected',
            ];
        }
        
        return ['threadSelected'];
    }

    public function threadSelected($threadId)
    {
        $this->activeThread = ChatThread::with(['student', 'internship.company'])->find($threadId);
        $this->markAsRead();
    }

    public function refreshMessages()
    {
        $this->markAsRead();
    }

    public function markAsRead()
    {
        if ($this->activeThread) {
            $this->activeThread->messages()
                ->where('sender_id', '!=', auth()->id())
                ->whereNull('read_at')
                ->update(['read_at' => now()]);
                
            $this->dispatch('messageReceived'); // Update sidebar badging
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

        broadcast(new MessageSent($message))->toOthers();

        $this->dispatch('messageReceived'); 
    }

    public function render()
    {
        $messages = [];
        
        if ($this->activeThread) {
            $messages = $this->activeThread->messages()->with('attachments')->oldest()->get();
        }

        return view('livewire.supervisor.chat-window', [
            'messages' => $messages,
        ]);
    }
}
