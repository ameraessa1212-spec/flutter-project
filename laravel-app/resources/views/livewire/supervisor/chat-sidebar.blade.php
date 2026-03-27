<div class="flex flex-col h-full bg-white dark:bg-gray-800">
    <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 space-y-3">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-bold text-gray-900 dark:text-white">المحادثات</h2>
        </div>
        <div class="relative">
            <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                <x-heroicon-o-magnifying-glass class="w-5 h-5 text-gray-400" />
            </div>
            <input 
                type="text" 
                wire:model.live.debounce.300ms="search" 
                class="block w-full rounded-lg border-0 py-2 pr-10 pl-3 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 sm:text-sm sm:leading-6 dark:bg-gray-700 dark:ring-gray-600 dark:text-white dark:placeholder-gray-400 dark:focus:ring-primary-500" 
                placeholder="بحث عن طالب أو شركة..."
            >
        </div>
    </div>

    <div class="flex-1 overflow-y-auto w-full p-2 space-y-1" >
        @forelse ($threads as $thread)
            @php
                $isActive = $activeThreadId === $thread->id;
                $lastMessage = $thread->messages->first();
                // We'll consider a thread having unread messages if the last message was sent by the student and read_at is null
                $isUnread = $lastMessage && $lastMessage->sender_id !== auth()->id() && is_null($lastMessage->read_at);
            @endphp
            <button 
                wire:click="$dispatch('threadSelected', { threadId: {{ $thread->id }} })"
                class="w-full relative flex items-center p-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors {{ $isActive ? 'bg-primary-50 dark:bg-primary-900/20 shadow-sm border border-primary-100 dark:border-primary-800/30' : '' }}"
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
                                
                                @if($lastMessage->message_type === 'text')
                                    {{ $lastMessage->body }}
                                @else
                                    <span class="text-gray-400 flex items-center gap-1">
                                        <x-heroicon-s-paper-clip class="w-3 h-3" />
                                        مرفق  
                                    </span>
                                @endif
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
            <div class="p-4 text-center text-sm text-gray-500 dark:text-gray-400">
                لا توجد محادثات حالياً
            </div>
        @endforelse
    </div>
</div>
