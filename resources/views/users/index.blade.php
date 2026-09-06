<x-app-layout>

    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Users
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">

            <div class="bg-white shadow-sm sm:rounded-lg">
                <div class="p-6">

                    {{-- Messages --}}
                    @if (session('success'))
                        <div style="background:#dcfce7; color:#166534; padding:12px; border-radius:6px; margin-bottom:16px;">
                            {{ session('success') }}
                        </div>
                    @endif

                    @if (session('error'))
                        <div style="background:#fee2e2; color:#991b1b; padding:12px; border-radius:6px; margin-bottom:16px;">
                            {{ session('error') }}
                        </div>
                    @endif

                    {{-- Header --}}
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                        <h1 style="font-size:24px; font-weight:700;">
                            Users List
                        </h1>

                        <a
                            href="{{ route('users.create') }}"
                            style="background:#2563eb; color:white; padding:10px 16px; border-radius:6px; text-decoration:none;"
                        >
                            + ایجاد کاربر
                        </a>
                    </div>

                    {{-- Users --}}
                    <div style="border:1px solid #e5e7eb; border-radius:8px; overflow:hidden;">

                        {{-- Table Header --}}
                        <div style="display:grid; grid-template-columns:2fr 3fr 1fr 3fr; padding:12px 16px; background:#f3f4f6; font-weight:600;">
                            <div>Name</div>
                            <div>Email</div>
                            <div>Role</div>
                            <div>Actions</div>
                        </div>

                        @foreach ($users as $user)

                            <div style="display:grid; grid-template-columns:2fr 3fr 1fr 3fr; align-items:center; padding:14px 16px; border-top:1px solid #e5e7eb;">

                                {{-- Name --}}
                                <div>
                                    {{ $user->name }}
                                </div>

                                {{-- Email --}}
                                <div>
                                    {{ $user->email }}
                                </div>

                                {{-- Role --}}
                                <div>
                                    @if ($user->role === 'admin')
                                        <span style="background:#dbeafe; color:#1e40af; padding:4px 8px; border-radius:5px; font-size:13px;">
                                            Admin
                                        </span>
                                    @else
                                        <span style="background:#f3f4f6; color:#374151; padding:4px 8px; border-radius:5px; font-size:13px;">
                                            User
                                        </span>
                                    @endif
                                </div>

                                {{-- Actions --}}
                                <div>

                                    <a
                                        href="{{ route('users.edit', $user) }}"
                                        style="color:#2563eb; text-decoration:none; margin-right:12px;"
                                    >
                                        Edit
                                    </a>

                                    <a
                                        href="{{ route('users.reset-password.form', $user) }}"
                                        style="color:#d97706; text-decoration:none; margin-right:12px;"
                                    >
                                        Reset Password
                                    </a>

                                    <form
                                        method="POST"
                                        action="{{ route('users.destroy', $user) }}"
                                        style="display:inline;"
                                        onsubmit="return confirm('Are you sure you want to delete this user?');"
                                    >
                                        @csrf
                                        @method('DELETE')

                                        <button
                                            type="submit"
                                            style="color:#dc2626; background:none; border:none; cursor:pointer; padding:0;"
                                        >
                                            Delete
                                        </button>
                                    </form>

                                </div>

                            </div>

                        @endforeach

                    </div>

                    {{-- Pagination --}}
                    <div style="margin-top:20px;">
                        {{ $users->links() }}
                    </div>

                </div>
            </div>

        </div>
    </div>

</x-app-layout>