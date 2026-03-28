<x-filament-panels::page>
    <div class="grid grid-cols-1 items-stretch gap-4 xl:min-h-[calc(100vh-12rem)] xl:grid-cols-[22rem_minmax(0,1fr)] 2xl:gap-6">
        <x-filament::section class="flex flex-col h-full overflow-hidden" content-classes="h-full flex flex-col p-0">
            <livewire:supervisor.chat-sidebar />
        </x-filament::section>

        <x-filament::section class="flex flex-col h-full overflow-hidden" content-classes="h-full flex flex-col p-0">
            <livewire:supervisor.chat-window />
        </x-filament::section>
    </div>
</x-filament-panels::page>