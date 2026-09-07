<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class UserFileUploadTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_create_user_with_file(): void
    {
        Storage::fake('local');

        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        $file = UploadedFile::fake()->create(
            'document.pdf',
            100,
            'application/pdf'
        );

        $response = $this
            ->actingAs($admin)
            ->post(route('users.store'), [
                'name' => 'Test User',
                'email' => 'test@example.com',
                'password' => 'password123',
                'password_confirmation' => 'password123',
                'role' => 'user',
                'file' => $file,
            ]);

        $response->assertRedirect(route('users.index'));

        $user = User::where('email', 'test@example.com')->first();

        $this->assertNotNull($user);
        $this->assertNotNull($user->file_path);

        Storage::disk('local')->assertExists($user->file_path);
    }

    public function test_admin_can_create_user_without_file(): void
    {
        Storage::fake('local');

        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        $response = $this
            ->actingAs($admin)
            ->post(route('users.store'), [
                'name' => 'Test User',
                'email' => 'test@example.com',
                'password' => 'password123',
                'password_confirmation' => 'password123',
                'role' => 'user',
            ]);

        $response->assertRedirect(route('users.index'));

        $user = User::where('email', 'test@example.com')->first();

        $this->assertNotNull($user);
        $this->assertNull($user->file_path);
    }

    public function test_uploaded_file_must_be_valid(): void
    {
        Storage::fake('local');

        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        $file = UploadedFile::fake()->create(
            'malware.exe',
            100,
            'application/octet-stream'
        );

        $response = $this
            ->actingAs($admin)
            ->post(route('users.store'), [
                'name' => 'Test User',
                'email' => 'test@example.com',
                'password' => 'password123',
                'password_confirmation' => 'password123',
                'role' => 'user',
                'file' => $file,
            ]);

        $response->assertSessionHasErrors('file');

        $this->assertDatabaseMissing('users', [
            'email' => 'test@example.com',
        ]);
    }

    public function test_admin_can_download_user_file(): void
    {
        Storage::fake('local');

        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        $user = User::factory()->create([
            'role' => 'user',
        ]);

        $filePath = $user->id . '/document.pdf';

        Storage::disk('local')->put(
            'user-files/' . $filePath,
            'test file content'
        );

        $user->update([
            'file_path' => 'user-files/' . $filePath,
        ]);

        $response = $this
            ->actingAs($admin)
            ->get(route('users.file', $user));

        $response->assertOk();
        $response->assertDownload('document.pdf');
    }

    public function test_user_file_is_deleted_when_user_is_deleted(): void
    {
        Storage::fake('local');

        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        $user = User::factory()->create([
            'role' => 'user',
        ]);

        $filePath = 'user-files/' . $user->id . '/document.pdf';

        Storage::disk('local')->put(
            $filePath,
            'test file content'
        );

        $user->update([
            'file_path' => $filePath,
        ]);

        Storage::disk('local')->assertExists($filePath);

        $response = $this
            ->actingAs($admin)
            ->delete(route('users.destroy', $user));

        $response->assertRedirect(route('users.index'));

        Storage::disk('local')->assertMissing($filePath);

        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
        ]);
    }
}