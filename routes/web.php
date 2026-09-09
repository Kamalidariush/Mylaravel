<?php

use App\Http\Controllers\UserController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');


// Users
Route::middleware(['auth', 'admin'])->group(function () {
    Route::resource('users', UserController::class);
});

Route::get('/users/{user}/file', [UserController::class, 'downloadFile'])
    ->middleware(['auth', 'admin'])
    ->name('users.file');


// Profile
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])
        ->name('profile.edit');

    Route::patch('/profile', [ProfileController::class, 'update'])
        ->name('profile.update');

    Route::delete('/profile', [ProfileController::class, 'destroy'])
        ->name('profile.destroy');
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
    }

    try {
        Redis::connection()->ping();
        $checks['redis'] = true;
    } catch (\Throwable $e) {
    }

    $ready = $checks['database'] && $checks['redis'];

    return response()->json([
        'status' => $ready ? 'ok' : 'not_ready',
        'checks' => $checks,
    ], $ready ? 200 : 503);
});


// Authentication routes
require __DIR__.'/auth.php';