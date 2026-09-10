<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $email = 'd@d.d';

        $user = User::firstOrNew([
            'email' => $email,
        ]);

        if (! $user->exists) {
            $user->name = 'Dariush';
            $user->password = Hash::make('admin123');
        }

        $user->role = 'admin';

        $user->save();
    }
}