<x-filament-panels::page>
    <div class="supervisor-chat-shell grid grid-cols-1 items-stretch gap-4 xl:min-h-[calc(100vh-12rem)] xl:grid-cols-[22rem_minmax(0,1fr)] 2xl:gap-6">
        <div class="min-h-[26rem] overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-700 dark:bg-gray-800 xl:h-full xl:min-h-0">
            <livewire:supervisor.chat-sidebar />
        </div>

        <div class="min-h-[34rem] overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-700 dark:bg-gray-800 xl:h-full xl:min-h-0">
            <livewire:supervisor.chat-window />
        </div>
    </div>

    <style>
        .supervisor-chat-shell {
            min-width: 0;
        }

        .supervisor-chat-shell > div {
            min-width: 0;
        }

        .supervisor-chat-shell .chat-fixed-icon,
        .supervisor-chat-shell .chat-fixed-icon svg {
            width: 1.25rem;
            height: 1.25rem;
            min-width: 1.25rem;
            min-height: 1.25rem;
            max-width: 1.25rem;
            max-height: 1.25rem;
            flex-shrink: 0;
        }

        .supervisor-chat-shell .chat-fixed-icon-lg,
        .supervisor-chat-shell .chat-fixed-icon-lg svg {
            width: 3rem;
            height: 3rem;
            min-width: 3rem;
            min-height: 3rem;
            max-width: 3rem;
            max-height: 3rem;
            flex-shrink: 0;
        }
    </style>
</x-filament-panels::page>
