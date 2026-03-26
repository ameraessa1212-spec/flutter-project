<div class="flex flex-col h-full w-full bg-gray-50 dark:bg-gray-900 relative">
    @if($activeThread)
        <!-- Header -->
        <div class="px-5 py-3 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 flex items-center justify-between shrink-0">
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
            
            <a href="{{ route('filament.admin-waslaa.resources.internships.edit', $activeThread->internship_id) }}" target="_blank" class="text-xs text-primary-600 dark:text-primary-400 hover:underline">
                تفاصيل التدريب
            </a>
        </div>

        <!-- Messages Area -->
        <div class="flex-1 overflow-y-auto p-4 space-y-4" id="chat-messages-container" x-data="{
                scrollToBottom() {
                    this.$el.scrollTop = this.$el.scrollHeight;
                }
            }" x-init="
                scrollToBottom();
                $watch('messages', () => { setTimeout(() => scrollToBottom(), 50) });
                Livewire.on('messageReceived', () => { setTimeout(() => scrollToBottom(), 50) });
            ">
            @forelse($messages as $message)
                @php
                    $isOwn = $message->sender_id === auth()->id();
                @endphp
                <div class="flex w-full {{ $isOwn ? 'justify-end' : 'justify-start' }}">
                    <div class="max-w-[75%] flex flex-col {{ $isOwn ? 'items-end' : 'items-start' }}">
                        <div class="p-3 rounded-2xl {{ $isOwn ? 'bg-primary-600 text-white rounded-tl-none' : 'bg-white dark:bg-gray-800 border border-gray-100 dark:border-gray-700 text-gray-800 dark:text-gray-100 rounded-tr-none shadow-sm' }}">
                            @if($message->message_type === 'text')
                                <p class="text-sm whitespace-pre-wrap leading-relaxed">{{ $message->body }}</p>
                            @else
                                <!-- Attachments -->
                                @if($message->attachments->count() > 0)
                                    <div class="flex flex-col gap-2">
                                        @foreach($message->attachments as $attachment)
                                            @if(Str::startsWith($attachment->mime_type, 'image/'))
                                                <a href="{{ Storage::url($attachment->file_path) }}" target="_blank">
                                                    <img src="{{ Storage::url($attachment->file_path) }}" class="rounded-lg max-h-48 object-cover border {{ $isOwn ? 'border-primary-500' : 'border-gray-200' }}" alt="Attachment">
                                                </a>
                                            @else
                                                <a href="{{ Storage::url($attachment->file_path) }}" target="_blank" class="flex items-center gap-2 p-2 rounded-lg bg-black/10 hover:bg-black/20 transition">
                                                    <x-heroicon-s-document class="w-5 h-5" />
                                                    <span class="text-sm underline shrink-0">{{ $attachment->file_name ?? 'ملف' }}</span>
                                                </a>
                                            @endif
                                        @endforeach
                                    </div>
                                @endif
                                @if($message->body)
                                    <p class="text-sm mt-2">{{ $message->body }}</p>
                                @endif
                            @endif
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
                <div class="flex flex-col items-center justify-center h-full text-gray-400">
                    <x-heroicon-o-chat-bubble-left-right class="w-12 h-12 mb-2 opacity-50" />
                    <p class="text-sm">لا توجد رسائل سابقة. ابدأ المحادثة الآن!</p>
                </div>
            @endforelse
        </div>

        <!-- Input Area -->
        <div class="px-4 py-3 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 shrink-0">
            <form wire:submit.prevent="sendMessage" class="flex items-end gap-2">
                <div class="flex-1 relative">
                    <textarea 
                        wire:model="newMessageBody" 
                        wire:keydown.enter.prevent="sendMessage"
                        rows="1"
                        placeholder="اكتب رسالة..."
                        class="w-full text-sm block rounded-full border-gray-300 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 focus:bg-white dark:focus:bg-gray-800 focus:ring-primary-500 focus:border-primary-500 px-4 py-3 resize-none hide-scrollbar max-h-32"
                        x-data="{ resize() { $el.style.height = 'auto'; $el.style.height = ($el.scrollHeight < 120 ? $el.scrollHeight : 120) + 'px' } }"
                        x-init="resize()"
                        @input="resize()"
                    ></textarea>
                </div>
                
                <button type="submit" 
                    class="shrink-0 p-3 bg-primary-600 hover:bg-primary-500 text-white rounded-full transition-colors flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed"
                    wire:loading.attr="disabled"
                    wire:target="sendMessage">
                    <x-heroicon-s-paper-airplane class="w-5 h-5 rtl:-scale-x-100" />
                </button>
            </form>
        </div>
    @else
        <div class="flex flex-col items-center justify-center h-full w-full text-gray-400 bg-white dark:bg-gray-800 rounded-xl">
            <x-heroicon-o-chat-bubble-oval-left-ellipsis class="w-16 h-16 mb-4 opacity-30 text-primary-500" />
            <h3 class="text-lg font-medium text-gray-500">اختر محادثة</h3>
            <p class="text-sm text-gray-400 mt-1">اختر طالباً من القائمة الجانبية لبدء التواصل</p>
        </div>
    @endif
</div>
