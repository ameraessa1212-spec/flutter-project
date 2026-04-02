<div class="flex flex-col h-full min-h-[34rem] bg-white dark:bg-gray-900 rounded-xl overflow-hidden">
    @if($activeThread)
        <div class="flex shrink-0 items-center justify-between gap-3 border-b border-gray-200 p-4 dark:border-white/10">
            <div class="flex items-center gap-3">
                <x-filament::avatar size="lg" :fallback="str($activeThread->student->name ?? 'ط')->limit(1, '')" />
                <div>
                    <h3 class="text-sm font-semibold text-gray-900 dark:text-white">{{ $activeThread->student->name }}</h3>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                        {{ $activeThread->internship->company->name ?? 'تدريب' }}
                    </p>
                </div>
            </div>
            
            <x-filament::button 
                tag="a" 
                href="{{ route('filament.admin-waslaa.resources.internships.edit', $activeThread->internship_id) }}" 
                target="_blank" 
                color="gray"
                size="sm"
                icon="heroicon-m-arrow-top-right-on-square">
                تفاصيل التدريب
            </x-filament::button>
        </div>

        <div
            class="flex-1 space-y-4 overflow-y-auto p-4 bg-gray-50 dark:bg-gray-950/50"
            id="chat-messages-container"
            x-data="{
                scrollToBottom() {
                    this.$nextTick(() => {
                        this.$el.scrollTop = this.$el.scrollHeight;
                    });
                },
                init() {
                    this.scrollToBottom();
                }
            }"
            x-init="init()"
            x-on:chat-window-updated.window="scrollToBottom()"
        >
            @forelse($messages as $message)
                @php
                    $isOwn = $message->sender_id === auth()->id();
                @endphp
                <div class="flex w-full {{ $isOwn ? 'justify-end' : 'justify-start' }}">
                    <div class="flex max-w-[85%] flex-col {{ $isOwn ? 'items-end' : 'items-start' }} sm:max-w-[75%]">
                        <x-filament::section compact class="!bg-transparent !p-0 !border-0 !shadow-none ring-0">
                            <div class="rounded-2xl p-3 {{ $isOwn ? 'rounded-tl-none bg-primary-600 text-white' : 'rounded-tr-none bg-white text-gray-800 shadow-sm dark:bg-gray-800 dark:text-gray-100 ring-1 ring-gray-950/5 dark:ring-white/10' }}">
                                <p class="text-sm leading-relaxed whitespace-pre-wrap">{{ $message->body ?: 'رسالة جديدة' }}</p>
                            </div>
                        </x-filament::section>
                        <span class="text-[10px] text-gray-500 mt-1 mx-1 flex items-center gap-1">
                            {{ $message->sent_at?->format('g:i A') }}
                            @if($isOwn)
                                @if($message->read_at)
                                    <x-filament::icon icon="heroicon-m-check-badge" class="w-3 h-3 text-primary-500" />
                                @else
                                    <x-filament::icon icon="heroicon-m-check" class="w-3 h-3 text-gray-400" />
                                @endif
                            @endif
                        </span>
                    </div>
                </div>
            @empty
                <div class="flex h-full items-center justify-center py-8">
                    <div class="w-full max-w-md text-center">
                        <x-filament::icon icon="heroicon-o-chat-bubble-left-right" class="w-14 h-14 mx-auto mb-4 text-gray-400 dark:text-gray-500" />
                        <p class="text-sm font-semibold text-gray-800 dark:text-gray-100">لا توجد رسائل سابقة</p>
                        <p class="mt-2 text-xs leading-6 text-gray-500 dark:text-gray-400">ابدأ المحادثة الآن، وستظهر الرسائل هنا بشكل منظم داخل هذه النافذة.</p>
                    </div>
                </div>
            @endforelse
        </div>

        <div class="shrink-0 border-t border-gray-200 p-4 dark:border-white/10 bg-white dark:bg-gray-900">
            <form wire:submit.prevent="sendMessage" class="flex items-end gap-2">
                <div class="flex-1 relative">
                    <x-filament::input.wrapper>
                        <textarea
                            wire:model="newMessageBody"
                            wire:keydown.enter.prevent="sendMessage"
                            rows="1"
                            placeholder="اكتب رسالة..."
                            class="block w-full border-0 bg-transparent py-2.5 px-3 text-sm text-gray-900 focus:ring-0 dark:text-white placeholder:text-gray-400 dark:placeholder:text-gray-500 resize-none max-h-32"
                            x-data="{ resize() { $el.style.height = 'auto'; $el.style.height = ($el.scrollHeight < 120 ? $el.scrollHeight : 120) + 'px' } }"
                            x-init="resize()"
                            @input="resize()"
                        ></textarea>
                    </x-filament::input.wrapper>
                </div>
                
                <x-filament::button 
                    type="submit" 
                    icon="heroicon-s-paper-airplane" 
                    class="rtl:-scale-x-100 shrink-0" 
                    wire:loading.attr="disabled"
                    wire:target="sendMessage">
                </x-filament::button>
            </form>
        </div>
    @else
        <div class="flex h-full min-h-[34rem] items-center justify-center p-6 bg-gray-50/50 dark:bg-gray-900/50">
            <div class="text-center max-w-sm">
                <x-filament::icon icon="heroicon-o-chat-bubble-oval-left-ellipsis" class="w-20 h-20 mx-auto mb-5 text-gray-400 dark:text-gray-500" />
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">اختر محادثة</h3>
                <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">اختر طالباً من القائمة الجانبية لعرض المحادثة وبدء التواصل داخل هذه النافذة.</p>
            </div>
        </div>
    @endif
</div>