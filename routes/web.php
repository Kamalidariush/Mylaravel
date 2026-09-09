<?php

use App\Http\Controllers\UserController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/users/{user}/file', [UserController::class, 'downloadFile'])
    ->name('users.file');

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');


// Profile
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});


// Health Checks

Route::get('/health/live', function () {
    return response()->json([
        'status' => 'ok',
    ], 200);
});

Route::get('/health/ready', function () {
    $checks = [
        'database' => false,
        'redis' => false,
    ];

    try {
        DB::connection()->getPdo();
        $checks['database'] = true;
    } catch (\Throwable $e) {
        // Database is not ready.
    }

    try {
        Redis::connection()->ping();
        $checks['redis'] = true;
    } catch (\Throwable $e) {
        // Redis is not ready.
    }

    $ready = $checks['database'] && $checks['redis'];

    return response()->json([
        'status' => $ready ? 'ok' : 'not_ready',
        'checks' => $checks,
    ], $ready ? 200 : 503);
});