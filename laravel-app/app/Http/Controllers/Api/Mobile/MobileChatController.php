<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\ChatThread;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MobileChatController extends Controller
{
    /**
     * Get chat messages between student and a support/admin user.
     * Uses the unified ChatThread + Message system.
     */
    public function getMessages(Request $request): JsonResponse
    {
        $user = $request->user();
        $receiverId = $request->input('receiver_id');

        $thread = ChatThread::where('student_id', $user->id)
            ->whereNull('internship_id')
            ->first();

        if (! $thread) {
            return response()->json([
                'status' => 'success',
                'data' => [],
            ]);
        }

        $messages = Message::where('thread_id', $thread->id)
            ->orderBy('sent_at', 'asc')
            ->get();

        // Mark messages from others as read
        Message::where('thread_id', $thread->id)
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'status' => 'success',
            'data' => $messages->map(fn($m) => [
                'id' => $m->id,
                'from_id' => $m->sender_id,
                'to_id' => $m->sender_id === $user->id ? ($receiverId ?? 0) : $user->id,
                'body' => $m->body,
                'attachment' => null,
                'seen' => $m->read_at !== null,
                'created_at' => $m->sent_at?->toISOString() ?? $m->created_at?->toISOString(),
            ]),
        ]);
    }

    /**
     * Send a message to support/admin.
     * Uses the unified ChatThread + Message system.
     */
    public function sendMessage(Request $request): JsonResponse
    {
        $request->validate([
            'receiver_id' => 'nullable|exists:users,id',
            'message' => 'required|string',
        ]);

        $user = $request->user();

        // Find or create a support thread (no internship_id = support thread)
        $thread = ChatThread::firstOrCreate(
            [
                'student_id' => $user->id,
                'internship_id' => null,
            ],
            [
                'status' => 'active',
                'last_message_at' => now(),
            ]
        );

        $message = Message::create([
            'thread_id' => $thread->id,
            'sender_id' => $user->id,
            'message_type' => 'text',
            'body' => $request->input('message'),
            'sent_at' => now(),
        ]);

        $thread->update(['last_message_at' => now()]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $message->id,
                'message' => $message->body,
                'receiver_id' => $request->input('receiver_id', 0),
            ],
        ]);
    }

    /**
     * Get a list of contacts for the student:
     * - Their internship supervisor (if available)
     * - System support admins
     */
    public function contacts(Request $request): JsonResponse
    {
        $user = $request->user();

        $supervisorUsers = collect();
        $internship = \App\Models\Internship::with('supervisor')
            ->where('student_id', $user->id)
            ->whereIn('status', ['active', 'pending'])
            ->latest()
            ->first();

        if ($internship && $internship->supervisor) {
            $supervisorUser = User::where('email', '=', $internship->supervisor->email)->first();
            if ($supervisorUser) {
                $supervisorUsers->push($supervisorUser);
            }
        }

        $supportAdmins = User::where('role', 'super_admin')
            ->orWhere('role', 'support')
            ->where('status', 'active')
            ->get();
        $contacts = $supervisorUsers->merge($supportAdmins)->unique('id')->values();

        return response()->json([
            'status' => 'success',
            'data' => $contacts->map(fn($u) => [
                'id'   => $u->id,
                'name' => $u->name,
                'role' => $u->role,
                'type' => in_array($u->role, ['super_admin', 'support']) ? 'support' : 'supervisor',
            ]),
        ]);
    }
}
