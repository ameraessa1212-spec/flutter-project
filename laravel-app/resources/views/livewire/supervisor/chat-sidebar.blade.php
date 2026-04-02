<div class="flex h-full flex-col">
    <div class="p-4 border-b border-gray-200 dark:border-white/10 shrink-0">
        <x-filament::input.wrapper prefix-icon="heroicon-m-magnifying-glass">
            <x-filament::input
                type="text"
                wire:model.live.debounce.300ms="search"
                placeholder="بحث عن طالب أو شركة..."
            />
        </x-filament::input.wrapper>
    </div>

    <div class="flex-1 overflow-y-auto p-2 space-y-2">
        @forelse ($threads as $thread)
            @php
                $isActive = $activeThreadId === $thread->id;
                $lastMessage = $thread->messages->first();
                $isUnread = $thread->unread_messages_count > 0;
            @endphp
            <button wire:click="$dispatch('threadSelected', { threadId: {{ $thread->id }} })" class="w-full text-right transition-colors block focus:outline-none rounded-xl {{ $isActive ? 'bg-primary-50 dark:bg-primary-900/20 ring-1 ring-primary-500' : 'hover:bg-gray-50 dark:hover:bg-white/5' }} p-3">
                <div class="flex items-center gap-3">
                    <x-filament::avatar size="lg" :fallback="str($thread->student->name)->limit(1, '')" />
                    <div class="flex-1 min-w-0">
                        <div class="flex justify-between items-center mb-1">
                            <span class="font-medium text-sm truncate text-gray-900 dark:text-white">{{ $thread->student->name }}</span>
                            <span class="text-xs text-gray-500">{{ $thread->last_message_at?->diffForHumans() }}</span>
                        </div>
                        <div class="text-xs text-gray-500 truncate mb-1">
                            {{ $thread->internship->company->name ?? 'تدريب عام' }}
                        </div>
                        <div class="text-xs flex justify-between items-center">
                            <span class="text-gray-600 dark:text-gray-400 truncate pr-1">
                                @if($lastMessage)
                                    @if($lastMessage->sender_id === auth()->id())
                                        <span class="text-gray-400">أنت: </span>
                                    @endif
                                    {{ str($lastMessage->body ?: 'رسالة جديدة')->limit(30) }}
                                @else
                                    <span class="text-gray-400">لا توجد رسائل...</span>
                                @endif
                            </span>
                            @if($isUnread)
                                <x-filament::badge color="primary" size="sm" class="rounded-full w-2 h-2 p-0 min-h-0 min-w-0"></x-filament::badge>
                            @endif
                        </div>
                    </div>
                </div>
            </button>
        @empty
            <div class="flex h-full items-center justify-center p-4">
                <div class="text-center text-gray-500 dark:text-gray-400 flex flex-col items-center">
                    <x-filament::icon icon="heroicon-o-chat-bubble-left-right" class="w-12 h-12 mb-3 text-gray-400" />
                    <p class="text-sm font-medium">لا توجد محادثات حالياً</p>
                </div>
            </div>
        @endforelse
    </div>
</div>