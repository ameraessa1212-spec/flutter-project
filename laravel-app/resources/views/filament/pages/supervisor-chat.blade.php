<x-filament-panels::page>
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 lg:gap-6 lg:h-[calc(100vh-14rem)] lg:min-h-[500px]">
        <!-- Sidebar -->
        <div class="col-span-1 border rounded-xl bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden shadow-sm h-[400px] lg:h-full">
            <livewire:supervisor.chat-sidebar />
        </div>

        <!-- Main Chat Area -->
        <div class="col-span-1 lg:col-span-2 border rounded-xl bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden shadow-sm h-[600px] lg:h-full">
            <livewire:supervisor.chat-window />
        </div>
    </div>
</x-filament-panels::page>
