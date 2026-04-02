<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChatThread;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function contacts(Request $request): JsonResponse
    {
        $search = $request->input('search');

        $query = User::whereIn('role', ['student', 'supervisor', 'examiner'])
            ->where('status', 'active')
            ->with('studentProfile.specialization');

        if ($search) {
            $query->where('name', 'like', "%{$search}%");
        }

        $users = $query->orderBy('name')->limit(50)->get()->map(function ($user) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'role' => $user->role,
                'initials' => mb_substr($user->name, 0, 1),
                'specialization' => $user->studentProfile?->specialization?->name,
            ];
        });

        return response()->json(['data' => $users]);
    }

    public function messages(Request $request): JsonResponse
    {
        $request->validate([
            'user_id' => ['required', 'exists:users,id'],
        ]);

        $userId = (int) $request->input('user_id');
        $currentUserId = $request->user()->id;

        $thread = ChatThread::where('student_id', $userId)->first();

        if (! $thread) {
            return response()->json(['data' => []]);
        }

        $messages = Message::where('thread_id', $thread->id)
            ->orderBy('sent_at')
            ->get()
            ->map(function ($msg) use ($currentUserId) {
                return [
                    'id' => $msg->id,
                    'body' => $msg->body,
                    'type' => $msg->message_type,
                    'is_mine' => $msg->sender_id === $currentUserId,
                    'sender_name' => $msg->sender?->name,
                    'sent_at' => $msg->sent_at?->toISOString(),
                    'time' => $msg->sent_at?->format('h:i A'),
                ];
            });

        Message::where('thread_id', $thread->id)
            ->where('sender_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['data' => $messages]);
    }

    public function send(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'exists:users,id'],
            'body' => ['required', 'string', 'max:5000'],
            'type' => ['nullable', 'string', 'in:text,voice,file'],
        ]);

        $thread = ChatThread::firstOrCreate(
            ['student_id' => $validated['user_id']],
            ['status' => 'active', 'last_message_at' => now()]
        );

        $message = Message::create([
            'thread_id' => $thread->id,
            'sender_id' => $request->user()->id,
            'message_type' => $validated['type'] ?? 'text',
            'body' => $validated['body'],
            'sent_at' => now(),
        ]);

        $thread->update(['last_message_at' => now()]);

        return response()->json([
            'message' => 'تم إرسال الرسالة.',
            'data' => [
                'id' => $message->id,
                'body' => $message->body,
                'type' => $message->message_type,
                'is_mine' => true,
                'sent_at' => $message->sent_at->toISOString(),
                'time' => $message->sent_at->format('h:i A'),
            ],
        ]);
    }
}
