<?php

namespace App\Http\Controllers\Api\Admin;

use App\Events\MessageSent;
use App\Http\Controllers\Controller;
use App\Models\ChatThread;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Throwable;

class ChatController extends Controller
{
    public function contacts(Request $request): JsonResponse
    {
        if ($request->user()->role === 'examiner') {
            return response()->json(['message' => 'غير مصرح بالوصول.'], 403);
        }

        $search = $request->input('search');

        // Chat is between admins and students only — return students exclusively.
        $query = User::where('role', 'student')
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
        if ($request->user()->role === 'examiner') {
            return response()->json(['message' => 'غير مصرح بالوصول.'], 403);
        }

        $request->validate([
            'user_id' => ['required', 'exists:users,id,role,student'],
        ]);

        $userId = (int) $request->input('user_id');
        $currentUserId = $request->user()->id;

        // Get all threads for this student and collect messages from all of them
        $threadIds = ChatThread::where('student_id', $userId)->pluck('id');

        if ($threadIds->isEmpty()) {
            return response()->json(['data' => []]);
        }

        $messages = Message::whereIn('thread_id', $threadIds)
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

        // Mark student's messages as read
        Message::whereIn('thread_id', $threadIds)
            ->where('sender_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['data' => $messages]);
    }

    public function send(Request $request): JsonResponse
    {
        if ($request->user()->role === 'examiner') {
            return response()->json(['message' => 'غير مصرح بالوصول.'], 403);
        }

        $validated = $request->validate([
            'user_id' => ['required', 'exists:users,id,role,student'],
            'body' => ['required', 'string', 'max:5000'],
            'type' => ['nullable', 'string', 'in:text,voice,file'],
        ]);

        // Find or create a support thread (no internship) for this student
        $thread = ChatThread::where('student_id', $validated['user_id'])
            ->whereNull('internship_id')
            ->first();

        if (! $thread) {
            $thread = ChatThread::create([
                'student_id' => $validated['user_id'],
                'internship_id' => null,
                'supervisor_id' => null,
                'status' => 'active',
                'last_message_at' => now(),
            ]);
        }

        $message = Message::create([
            'thread_id' => $thread->id,
            'sender_id' => $request->user()->id,
            'message_type' => $validated['type'] ?? 'text',
            'body' => $validated['body'],
            'sent_at' => now(),
        ]);

        $thread->update(['last_message_at' => now()]);

        try {
            broadcast(new MessageSent($message))->toOthers();
        } catch (Throwable $e) {
            report($e);
        }

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
