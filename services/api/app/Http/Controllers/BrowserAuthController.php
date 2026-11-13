<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class BrowserAuthController extends Controller
{
    public function csrf(Request $request)
    {
        return response()->json(['csrf_token' => $request->session()->token()]);
    }

    public function login(Request $request)
    {
        $credentials = $request->validate(['email' => ['required', 'email'], 'password' => ['required', 'string']]);
        if (! Auth::guard('web')->attempt([...$credentials, 'status' => 'active'])) {
            throw ValidationException::withMessages(['email' => ['The provided credentials are incorrect.']]);
        }
        $request->session()->regenerate();

        return response()->json(['user' => Auth::guard('web')->user()->load(['profile', 'settings'])]);
    }

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
            // Browser sessions do not mint a mobile bearer token.
        ]);
        $user->profile()->create(['privacy_consent_at' => now()]);
        $user->settings()->create();
        Auth::guard('web')->login($user);
        $request->session()->regenerate();

        return response()->json(['user' => $user->load(['profile', 'settings'])], 201);
    }

    public function me(Request $request)
    {
        $user = Auth::guard('web')->user();
        if (! $user || $user->status !== 'active') {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        return response()->json(['user' => $user->load(['profile', 'settings'])]);
    }

    public function logout(Request $request)
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json(['message' => 'Signed out.']);
    }
}
