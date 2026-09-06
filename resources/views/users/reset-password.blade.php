<x-app-layout>

```
<x-slot name="header">
    <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
        Reset Password
    </h2>
</x-slot>

<div style="max-width:600px; margin:40px auto; padding:20px;">

    <div style="
        background:white;
        padding:30px;
        border-radius:8px;
        box-shadow:0 2px 8px rgba(0,0,0,0.1);
    ">

        <h3 style="font-size:20px; margin-bottom:25px;">
            Reset Password for {{ $user->name }}
        </h3>

        @if ($errors->any())
            <div style="
                background:#fee2e2;
                color:#991b1b;
                padding:12px;
                border-radius:6px;
                margin-bottom:20px;
            ">
                <ul style="margin:0; padding-left:20px;">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form method="POST" action="{{ route('users.reset-password', $user) }}">
            @csrf

            <div style="margin-bottom:20px;">
                <label
                    for="password"
                    style="display:block; margin-bottom:8px; font-weight:600;"
                >
                    New Password
                </label>

                <input
                    id="password"
                    type="password"
                    name="password"
                    required
                    minlength="8"
                    style="
                        width:100%;
                        padding:10px;
                        border:1px solid #d1d5db;
                        border-radius:6px;
                        box-sizing:border-box;
                    "
                >
            </div>

            <div style="margin-bottom:25px;">
                <label
                    for="password_confirmation"
                    style="display:block; margin-bottom:8px; font-weight:600;"
                >
                    Confirm New Password
                </label>

                <input
                    id="password_confirmation"
                    type="password"
                    name="password_confirmation"
                    required
                    minlength="8"
                    style="
                        width:100%;
                        padding:10px;
                        border:1px solid #d1d5db;
                        border-radius:6px;
                        box-sizing:border-box;
                    "
                >
            </div>

            <div style="display:flex; gap:10px;">

                <a
                    href="{{ route('users.index') }}"
                    style="
                        background:#6b7280;
                        color:white;
                        padding:10px 16px;
                        border-radius:6px;
                        text-decoration:none;
                    "
                >
                    Cancel
                </a>

                <button
                    type="submit"
                    style="
                        background:#dc2626;
                        color:white;
                        padding:10px 16px;
                        border-radius:6px;
                        border:none;
                        cursor:pointer;
                    "
                >
                    Reset Password
                </button>

            </div>

        </form>

    </div>

</div>
```

</x-app-layout>
