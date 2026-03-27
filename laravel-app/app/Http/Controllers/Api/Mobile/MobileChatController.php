<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\User;
use Chatify\Facades\ChatifyMessenger as Chatify;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\ChMessage; 
use Illuminate\Support\Str;

class MobileChatController extends Controller
{
    /**
     * Get chat history for Student Support (User ID 1).
     * If receiver_id is not provided, it defaults to 1 (System Support).
     */
    public function getMessages(Request $request): JsonResponse
    {
        $user = $request->user();
        $receiver_id = $request->input('receiver_id', 1);

        $messages = DB::table('ch_messages')
            ->where(function ($query) use ($user, $receiver_id) {
                $query->where('from_id', $user->id)
                      ->where('to_id', $receiver_id);
            })
            ->orWhere(function ($query) use ($user, $receiver_id) {
                $query->where('from_id', $receiver_id)
                      ->where('to_id', $user->id);
            });

        if ($receiver_id == 1) {
            $staffIds = User::role(['super_admin', 'supervisor', 'support'])->pluck('id');
            $messages->orWhere(function ($query) use ($user, $staffIds) {
                $query->whereIn('from_id', $staffIds)
                      ->where('to_id', $user->id);
            });
        }

        $list = $messages->orderBy('created_at', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $list->map(fn($m) => [
                'id' => $m->id,
                'from_id' => (int) $m->from_id,
                'to_id' => (int) $m->to_id,
                'body' => $m->body,
                'attachment' => $m->attachment ? json_decode($m->attachment) : null,
                'seen' => (bool) $m->seen,
                'created_at' => $m->created_at,
            ]),
        ]);
    }

    /**
     * Send a message to System Support (User ID 1) or a specific user.
     */
    public function sendMessage(Request $request): JsonResponse
    {
        $request->validate([
            'receiver_id' => 'nullable|exists:users,id',
            'message' => 'required|string',
        ]);

        $user = $request->user();
        $receiver_id = $request->input('receiver_id', 1);

        $messageId = (string) Str::uuid();
        DB::table('ch_messages')->insert([
            'id' => $messageId,
            'from_id' => $user->id,
            'to_id' => $receiver_id,
            'body' => $request->message,
            'attachment' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $messageId,
                'message' => $request->message,
                'receiver_id' => $receiver_id,
            ],
        ]);
    }

    /**
     * List of students who messaged System Support (for Supervisors/Admins).
     */
    public function supportQueue(Request $request): JsonResponse
    {
        if (!$request->user()->hasAnyRole(['super_admin', 'supervisor', 'support'])) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $studentIds = DB::table('ch_messages')
            ->where('to_id', 1)
            ->distinct()
            ->pluck('from_id');

        $students = User::whereIn('id', $studentIds)->get();

        return response()->json([
            'status' => 'success',
            'data' => $students->map(function ($s) {
                $lastMsg = DB::table('ch_messages')
                    ->where('from_id', $s->id)
                    ->where('to_id', 1)
                    ->orderByDesc('created_at')
                    ->first();

                return [
                    'id' => $s->id,
                    'name' => $s->name,
                    'last_message' => $lastMsg ? $lastMsg->body : null,
                    'unread_count' => DB::table('ch_messages')
                        ->where('from_id', $s->id)
                        ->where('to_id', 1)
                        ->where('seen', 0)
                        ->count(),
                ];
            }),
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
            $supervisorUser = \App\Models\User::where('email', '=', $internship->supervisor->email)->first();
            if ($supervisorUser) {
                $supervisorUsers->push($supervisorUser);
            }
        }

        $supportAdmins = User::role(['super_admin', 'support'])->get();
        $contacts = $supervisorUsers->merge($supportAdmins)->unique('id')->values();

        return response()->json([
            'status' => 'success',
            'data' => $contacts->map(fn($u) => [
                'id'   => $u->id,
                'name' => $u->name,
                'role' => $u->getRoleNames()->first(),
                'type' => $u->hasAnyRole(['super_admin', 'support']) ? 'support' : 'supervisor',
            ]),
        ]);
    }
}
