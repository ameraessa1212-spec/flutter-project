<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Mobile\StoreAttachmentMessageRequest;
use App\Http\Requests\Api\Mobile\StoreMessageRequest;
use App\Http\Resources\Mobile\MessageResource;
use App\Models\ChatThread;
use App\Models\Message;
use App\Models\MessageAttachment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function index(Request $request, ChatThread $thread): JsonResponse
    {
        $this->authorize('view', $thread);

        $messages = Message::query()
            ->with('attachments')
            ->where('thread_id', $thread->id)
            ->orderByDesc('created_at')
            ->paginate((int) $request->integer('per_page', 30));

        return MessageResource::collection($messages)->response();
    }

    public function store(StoreMessageRequest $request, ChatThread $thread): JsonResponse
    {
        $this->authorize('view', $thread);

        $validated = $request->validated();

        $message = Message::query()->create([
            'thread_id' => $thread->id,
            'sender_id' => $request->user()->id,
            'message_type' => 'text',
            'body' => $validated['body'],
            'sent_at' => now(),
        ]);

        $thread->update(['last_message_at' => now()]);

        return response()->json([
            'message' => 'Message sent successfully.',
            'data' => MessageResource::make($message),
        ], 201);
    }

    public function storeAttachment(StoreAttachmentMessageRequest $request, ChatThread $thread): JsonResponse
    {
        $this->authorize('view', $thread);

        $validated = $request->validated();

        $message = Message::query()->create([
            'thread_id' => $thread->id,
            'sender_id' => $request->user()->id,
            'message_type' => $validated['message_type'] ?? 'file',
            'body' => $validated['body'] ?? null,
            'sent_at' => now(),
        ]);

        $file = $validated['attachment'];
        $path = $file->store('mobile/chat/attachments', 'public');

        MessageAttachment::query()->create([
            'message_id' => $message->id,
            'file_path' => $path,
            'file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getClientMimeType(),
            'file_size' => $file->getSize(),
        ]);

        $thread->update(['last_message_at' => now()]);

        return response()->json([
            'message' => 'Attachment message sent successfully.',
            'data' => MessageResource::make($message->load('attachments')),
        ], 201);
    }

    public function markRead(Request $request, ChatThread $thread): JsonResponse
    {
        $this->authorize('view', $thread);

        Message::query()
            ->where('thread_id', $thread->id)
            ->whereNull('read_at')
            ->where('sender_id', '!=', $request->user()->id)
            ->update(['read_at' => now()]);

        return response()->json([
            'message' => 'Messages marked as read.',
        ]);
    }
}
