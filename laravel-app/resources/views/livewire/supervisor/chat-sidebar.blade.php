<div class="flex h-full min-h-0 flex-col bg-white dark:bg-gray-800">
    <div class="space-y-3 border-b border-gray-200 bg-white px-4 py-4 dark:border-gray-700 dark:bg-gray-800">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-bold text-gray-900 dark:text-white">المحادثات</h2>
        </div>
        <div class="relative">
            <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                <span class="chat-fixed-icon text-gray-400">
                    <x-heroicon-o-magnifying-glass class="chat-fixed-icon" />
                </span>
            </div>
            <input 
                type="text" 
                wire:model.live.debounce.300ms="search" 
                class="block w-full rounded-lg border-0 py-2 pr-10 pl-3 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 sm:text-sm sm:leading-6 dark:bg-gray-700 dark:ring-gray-600 dark:text-white dark:placeholder-gray-400 dark:focus:ring-primary-500" 
                placeholder="بحث عن طالب أو شركة..."
            >
        </div>
    </div>

    <div class="flex-1 space-y-1 overflow-y-auto p-2">
        @forelse ($threads as $thread)
            @php
                $isActive = $activeThreadId === $thread->id;
                $lastMessage = $thread->messages->first();
                $isUnread = $thread->unread_messages_count > 0;
            @endphp
            <button 
                wire:click="$dispatch('threadSelected', { threadId: {{ $thread->id }} })"
                class="relative flex w-full items-center rounded-xl p-3 text-right transition-colors hover:bg-gray-100 dark:hover:bg-gray-700 {{ $isActive ? 'border border-primary-100 bg-primary-50 shadow-sm dark:border-primary-800/30 dark:bg-primary-900/20' : '' }}"
            >
                <div class="flex-shrink-0 relative">
                    <div class="w-12 h-12 rounded-full flex items-center justify-center text-xl font-bold bg-primary-100 text-primary-600 dark:bg-primary-900 dark:text-primary-300">
                        {{ str($thread->student->name ?? 'ط')->limit(1, '') }}
                    </div>
                </div>

                <div class="mr-3 flex-1 overflow-hidden text-right">
                    <div class="flex justify-between items-center mb-1">
                        <h3 class="text-sm font-semibold truncate text-gray-900 dark:text-gray-100">{{ $thread->student->name }}</h3>
                        <span class="text-xs text-gray-500 dark:text-gray-400 whitespace-nowrap hidden sm:block">
                            {{ $thread->last_message_at ? $thread->last_message_at->diffForHumans() : '' }}
                        </span>
                    </div>
                    <div class="text-xs text-gray-500 dark:text-gray-400 mb-1 truncate">
                        {{ $thread->internship->company->name ?? 'تدريب عام' }}
                    </div>
                    <div class="text-xs text-gray-600 dark:text-gray-300 truncate font-medium flex justify-between items-center">
                        <span class="truncate pr-1">
                            @if($lastMessage)
                                @if($lastMessage->sender_id === auth()->id())
                                    <span class="text-gray-400">أنت: </span>
                                @endif

                                {{ $lastMessage->body ?: 'رسالة جديدة' }}
                            @else
                                <span class="text-gray-400">لا توجد رسائل...</span>
                            @endif
                        </span>
                        
                        @if($isUnread)
                            <div class="w-2.5 h-2.5 bg-primary-600 rounded-full"></div>
                        @endif
                    </div>
                </div>
            </button>
        @empty
            <div class="flex h-full min-h-[14rem] items-center justify-center p-4">
                <div class="w-full max-w-xs rounded-2xl border border-dashed border-gray-200 bg-gray-50/70 px-5 py-8 text-center dark:border-gray-700 dark:bg-gray-900/40">
                    <div class="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-primary-50 text-primary-600 dark:bg-primary-900/30 dark:text-primary-300">
                        <span class="chat-fixed-icon">
                            <x-heroicon-o-chat-bubble-left-right class="chat-fixed-icon" />
                        </span>
                    </div>
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-200">لا توجد محادثات حالياً</p>
                    <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">ستظهر هنا محادثات الطلاب بعد بدء التواصل.</p>
                </div>
            </div>
        @endforelse
    </div>
</div>
