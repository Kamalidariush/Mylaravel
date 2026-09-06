<x-app-layout>

    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Dashboard
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                    <h3 class="text-lg font-semibold">
                        Welcome
                    </h3>

                    <p class="mt-2 text-gray-600">
                        {{ auth()->user()->name }}
                    </p>
                </div>

                @if(auth()->user()->role === 'admin')

                    <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                        <h3 class="text-lg font-semibold">
                            User Management
                        </h3>

                        <p class="mt-2 text-gray-600">
                            Manage system users.
                        </p>

                        <a
                            href="{{ route('users.index') }}"
                            class="inline-block mt-4 px-4 py-2 bg-gray-800 text-white rounded-md"
                        >
                            Manage Users
                        </a>
                    </div>

                @endif

                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                    <h3 class="text-lg font-semibold">
                        Profile
                    </h3>

                    <p class="mt-2 text-gray-600">
                        Manage your profile.
                    </p>

                    <a
                        href="{{ route('profile.edit') }}"
                        class="inline-block mt-4 px-4 py-2 bg-gray-200 rounded-md"
                    >
                        My Profile
                    </a>
                </div>

            </div>

        </div>
    </div>

</x-app-layout>