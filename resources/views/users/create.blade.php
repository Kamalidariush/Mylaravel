<x-app-layout>

    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Add User
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-4xl mx-auto sm:px-6 lg:px-8">

            <div class="bg-white shadow-sm sm:rounded-lg p-6">

                <form method="POST" action="{{ route('users.store') }}">
                    @csrf

                    {{-- Name --}}
                    <div class="mb-4">
                        <label class="block font-medium text-sm text-gray-700">
                            Name
                        </label>

                        <input
                            type="text"
                            name="name"
                            value="{{ old('name') }}"
                            class="block mt-1 w-full rounded-md border-gray-300"
                            required
                        >

                        @error('name')
                            <div class="text-red-600 text-sm mt-1">
                                {{ $message }}
                            </div>
                        @enderror
                    </div>

                    {{-- Email --}}
                    <div class="mb-4">
                        <label class="block font-medium text-sm text-gray-700">
                            Email
                        </label>

                        <input
                            type="email"
                            name="email"
                            value="{{ old('email') }}"
                            class="block mt-1 w-full rounded-md border-gray-300"
                            required
                        >

                        @error('email')
                            <div class="text-red-600 text-sm mt-1">
                                {{ $message }}
                            </div>
                        @enderror
                    </div>

                    {{-- Role --}}
                    <div class="mb-4">
                        <label style="display:block; font-weight:600; margin-bottom:6px;">
                            Role
                        </label>

                        <select
                            name="role"
                            style="width:100%; padding:10px; border:1px solid #d1d5db; border-radius:6px;"
                            required
                        >
                            <option value="user" {{ old('role', 'user') === 'user' ? 'selected' : '' }}>
                                User
                            </option>

                            <option value="admin" {{ old('role') === 'admin' ? 'selected' : '' }}>
                                Admin
                            </option>
                        </select>

                        @error('role')
                            <div style="color:#dc2626; font-size:14px; margin-top:4px;">
                                {{ $message }}
                            </div>
                        @enderror
                    </div>

                    {{-- Password --}}
                    <div class="mb-4">
                        <label class="block font-medium text-sm text-gray-700">
                            Password
                        </label>

                        <input
                            type="password"
                            name="password"
                            class="block mt-1 w-full rounded-md border-gray-300"
                            required
                        >

                        @error('password')
                            <div class="text-red-600 text-sm mt-1">
                                {{ $message }}
                            </div>
                        @enderror
                    </div>

                    {{-- Confirm Password --}}
                    <div class="mb-6">
                        <label class="block font-medium text-sm text-gray-700">
                            Confirm Password
                        </label>

                        <input
                            type="password"
                            name="password_confirmation"
                            class="block mt-1 w-full rounded-md border-gray-300"
                            required
                        >
                    </div>

                    {{-- Buttons --}}
                    <div class="flex gap-3">

                        <button
                            type="submit"
                            style="background-color:#2563eb; color:white; padding:10px 16px; border-radius:6px; border:none; cursor:pointer;"
                        >
                            Create User
                        </button>

                        <a
                            href="{{ route('users.index') }}"
                            style="background-color:#e5e7eb; color:#111827; padding:10px 16px; border-radius:6px; text-decoration:none;"
                        >
                            Cancel
                        </a>

                    </div>

                </form>

            </div>
        </div>
    </div>

</x-app-layout>