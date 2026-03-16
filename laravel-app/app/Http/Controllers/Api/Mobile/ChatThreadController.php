<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Resources\Mobile\ChatThreadResource;
use App\Models\ChatThread;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatThreadController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $threads = ChatThread::query()
            ->with(['internship.company', 'supervisor'])
            ->where('student_id', $request->user()->id)
            ->orderByDesc('last_message_at')
            ->paginate((int) $request->integer('per_page', 20));

        return ChatThreadResource::collection($threads)->response();
    }

    public function show(Request $request, ChatThread $thread): JsonResponse
    {
        $this->authorize('view', $thread);

        $thread->load(['internship.company', 'supervisor']);

        return response()->json([
            'data' => ChatThreadResource::make($thread),
        ]);
    }
}
