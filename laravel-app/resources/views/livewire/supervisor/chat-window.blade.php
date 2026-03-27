<div class="relative flex h-full min-h-[34rem] min-w-0 flex-col bg-gray-50 dark:bg-gray-900 xl:min-h-0">
    @if($activeThread)
        <div class="flex shrink-0 items-center justify-between gap-3 border-b border-gray-200 bg-white px-5 py-4 dark:border-gray-700 dark:bg-gray-800">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg font-bold bg-primary-100 text-primary-600 dark:bg-primary-900 dark:text-primary-300">
                    {{ str($activeThread->student->name ?? 'ط')->limit(1, '') }}
                </div>
                <div>
                    <h3 class="text-sm font-semibold text-gray-900 dark:text-gray-100">{{ $activeThread->student->name }}</h3>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                        {{ $activeThread->internship->company->name ?? 'تدريب' }}
                    </p>
                </div>
            </div>
            
            <a href="{{ route('filament.admin-waslaa.resources.internships.edit', $activeThread->internship_id) }}" target="_blank" class="hidden text-xs text-primary-600 hover:underline dark:text-primary-400 sm:block">
                تفاصيل التدريب
            </a>
        </div>

        <div
            class="flex-1 space-y-4 overflow-y-auto p-4"
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
                        <div class="rounded-2xl p-3 {{ $isOwn ? 'rounded-tl-none bg-primary-600 text-white' : 'rounded-tr-none border border-gray-100 bg-white text-gray-800 shadow-sm dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100' }}">
                            <p class="text-sm leading-relaxed whitespace-pre-wrap">{{ $message->body ?: 'رسالة جديدة' }}</p>
                        </div>
                        <span class="text-[10px] text-gray-500 mt-1 mx-1">
                            {{ $message->sent_at?->format('g:i A') }}
                            @if($isOwn)
                                @if($message->read_at)
                                    <span class="text-primary-500 text-[10px] ml-1">✓ مقروء</span>
                                @endif
                            @endif
                        </span>
                    </div>
                </div>
            @empty
                <div class="flex min-h-full items-center justify-center py-8">
                    <div class="w-full max-w-md rounded-3xl border border-dashed border-gray-200 bg-white/90 px-6 py-10 text-center shadow-sm dark:border-gray-700 dark:bg-gray-800/90">
                        <div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-primary-50 text-primary-600 dark:bg-primary-900/30 dark:text-primary-300">
                            <span class="chat-fixed-icon-lg">
                                <x-heroicon-o-chat-bubble-left-right class="chat-fixed-icon-lg" />
                            </span>
                        </div>
                        <p class="text-sm font-semibold text-gray-800 dark:text-gray-100">لا توجد رسائل سابقة</p>
                        <p class="mt-2 text-xs leading-6 text-gray-500 dark:text-gray-400">ابدأ المحادثة الآن، وستظهر الرسائل هنا بشكل منظم داخل هذه النافذة.</p>
                    </div>
                </div>
            @endforelse
        </div>

        <div class="shrink-0 border-t border-gray-200 bg-white px-4 py-3 dark:border-gray-700 dark:bg-gray-800">
            <form wire:submit.prevent="sendMessage" class="flex items-end gap-2">
                <div class="flex-1 relative">
                    <textarea 
                        wire:model="newMessageBody" 
                        wire:keydown.enter.prevent="sendMessage"
                        rows="1"
                        placeholder="اكتب رسالة..."
                        class="block max-h-32 w-full resize-none rounded-2xl border-gray-300 bg-gray-50 px-4 py-3 text-sm focus:border-primary-500 focus:bg-white focus:ring-primary-500 dark:border-gray-600 dark:bg-gray-700 dark:focus:bg-gray-800"
                        x-data="{ resize() { $el.style.height = 'auto'; $el.style.height = ($el.scrollHeight < 120 ? $el.scrollHeight : 120) + 'px' } }"
                        x-init="resize()"
                        @input="resize()"
                    ></textarea>
                </div>
                
                <button type="submit" 
                    class="flex shrink-0 items-center justify-center rounded-full bg-primary-600 p-3 text-white transition-colors hover:bg-primary-500 disabled:cursor-not-allowed disabled:opacity-50"
                    wire:loading.attr="disabled"
                    wire:target="sendMessage">
                    <x-heroicon-s-paper-airplane class="w-5 h-5 rtl:-scale-x-100" />
                </button>
            </form>
        </div>
    @else
        <div class="flex h-full min-h-[34rem] items-center justify-center bg-[radial-gradient(circle_at_top,_rgba(59,130,246,0.08),_transparent_40%),linear-gradient(180deg,rgba(255,255,255,0.98),rgba(249,250,251,0.98))] px-6 py-10 text-gray-400 dark:bg-[radial-gradient(circle_at_top,_rgba(59,130,246,0.16),_transparent_35%),linear-gradient(180deg,rgba(17,24,39,0.98),rgba(3,7,18,0.98))]">
            <div class="mx-auto flex w-full max-w-lg flex-col items-center rounded-[2rem] border border-white/70 bg-white/90 px-8 py-10 text-center shadow-[0_24px_80px_-40px_rgba(15,23,42,0.45)] backdrop-blur dark:border-gray-700/80 dark:bg-gray-900/85">
                <div class="mb-5 flex h-20 w-20 items-center justify-center rounded-full bg-primary-50 text-primary-600 ring-8 ring-primary-50/60 dark:bg-primary-900/30 dark:text-primary-300 dark:ring-primary-900/20">
                    <span class="chat-fixed-icon-lg">
                        <x-heroicon-o-chat-bubble-oval-left-ellipsis class="chat-fixed-icon-lg" />
                    </span>
                </div>
                <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-100">اختر محادثة</h3>
                <p class="mt-2 max-w-sm text-sm leading-7 text-gray-500 dark:text-gray-400">اختر طالباً من القائمة الجانبية لعرض المحادثة وبدء التواصل داخل هذه النافذة.</p>
            </div>
        </div>
    @endif
</div>
