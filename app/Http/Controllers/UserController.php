<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     */
    public function index()
    {
        $users = User::latest()->paginate(10);

        return view('users.index', compact('users'));
    }

    /**
     * Show the form for creating a new user.
     */
    public function create()
    {
        return view('users.create');
    }

    /**
     * Store a newly created user.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],

            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,email',
            ],

            'password' => [
                'required',
                'confirmed',
                'min:8',
            ],

            'role' => [
                'required',
                'in:user,admin',
            ],

            'file' => [
                'nullable',
                'file',
                'max:5120',
                'mimes:pdf,jpg,jpeg,png,doc,docx',
            ],
        ]);

        // Create user first so we have the user's ID.
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => bcrypt($validated['password']),
            'role' => $validated['role'],
        ]);

        // Store uploaded file in the user's private directory.
        if ($request->hasFile('file')) {
            $filePath = $request->file('file')->store(
                'user-files/' . $user->id
            );

            $user->update([
                'file_path' => $filePath,
            ]);
        }

        return redirect()
            ->route('users.index')
            ->with('success', 'User created successfully.');
    }

    /**
     * Display the specified user.
     */
    public function show(User $user)
    {
        return view('users.show', compact('user'));
    }

    /**
     * Show the form for editing the specified user.
     */
    public function edit(User $user)
    {
        return view('users.edit', compact('user'));
    }

    /**
     * Update the specified user.
     */
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
            ],

            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,email,' . $user->id,
            ],

            'role' => [
                'required',
                'in:user,admin',
            ],

            'file' => [
                'nullable',
                'file',
                'max:5120',
                'mimes:pdf,jpg,jpeg,png,doc,docx',
            ],
        ]);

        $user->update([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'role' => $validated['role'],
        ]);

        /*
         * If a new file was uploaded:
         * 1. Delete the old file.
         * 2. Store the new file.
         * 3. Update file_path.
         */
        if ($request->hasFile('file')) {

            if ($user->file_path) {
                Storage::disk('local')->delete($user->file_path);
            }

            $filePath = $request->file('file')->store(
                'user-files/' . $user->id
            );

            $user->update([
                'file_path' => $filePath,
            ]);
        }

        return redirect()
            ->route('users.index')
            ->with('success', 'User updated successfully.');
    }

    /**
     * Remove the specified user.
     */
    public function destroy(User $user)
    {
        // Prevent deleting the currently authenticated user.
        if ($user->id === auth()->id()) {
            return redirect()
                ->route('users.index')
                ->with('error', 'You cannot delete your own account.');
        }

        // Delete user's file if it exists.
        if ($user->file_path) {
            Storage::disk('local')->delete($user->file_path);
        }

        // Delete user.
        $user->delete();

        return redirect()
            ->route('users.index')
            ->with('success', 'User deleted successfully.');
    }

    /**
     * Show reset password form.
     */
    public function showResetPassword(User $user)
    {
        return view('users.reset-password', compact('user'));
    }

    /**
     * Reset user's password.
     */
    public function resetPassword(Request $request, User $user)
    {
        $validated = $request->validate([
            'password' => [
                'required',
                'confirmed',
                'min:8',
            ],
        ]);

        $user->update([
            'password' => bcrypt($validated['password']),
        ]);

        return redirect()
            ->route('users.index')
            ->with('success', 'Password reset successfully.');
    }
    public function downloadFile(User $user)
    {
        if (!$user->file_path) {
            abort(404);
        }

        if (!Storage::disk('local')->exists($user->file_path)) {
            abort(404);
        }

        return Storage::disk('local')->download($user->file_path);
    }
}