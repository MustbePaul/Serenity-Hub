<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends ApiController
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'privacy_consent' => ['accepted'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'api_token' => hash('sha256', Str::random(80)),
        ]);

        $user->profile()->create([
            'privacy_consent_at' => now(),
        ]);
        $user->settings()->create();

        return $this->success([
            'token' => $user->api_token,
            'user' => $this->userPayload($user),
        ], 'Account created successfully.', status: 201);
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $user->forceFill([
            'api_token' => hash('sha256', Str::random(80)),
            'last_login_at' => now(),
        ])->save();

        return $this->success([
            'token' => $user->api_token,
            'user' => $this->userPayload($user),
        ], 'Logged in successfully.');
    }

    public function me(Request $request)
    {
        return $this->success($this->userPayload($request->user()));
    }

    public function logout(Request $request)
    {
        $request->user()->forceFill(['api_token' => null])->save();

        return $this->success(null, 'Logged out successfully.');
    }

    private function userPayload(User $user): array
    {
        $user->loadMissing(['profile', 'settings']);

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'status' => $user->status,
            'profile' => $user->profile,
            'settings' => $user->settings,
        ];
    }
}
