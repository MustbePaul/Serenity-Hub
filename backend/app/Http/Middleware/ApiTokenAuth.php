<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;

class ApiTokenAuth
{
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if (! $token) {
            return response()->json(['success' => false, 'message' => 'Unauthenticated.', 'errors' => (object) []], 401);
        }

        $user = User::where('api_token', $token)->where('status', 'active')->first();

        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Invalid or expired token.', 'errors' => (object) []], 401);
        }

        $request->setUserResolver(fn () => $user);

        return $next($request);
    }
}
