<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ApiTokenAuth
{
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if (! $token) {
            $user = Auth::guard('web')->user();
            if (! $user || $user->status !== 'active') {
                return response()->json(['success' => false, 'message' => 'Unauthenticated.', 'errors' => (object) []], 401);
            }
            if (! $request->isMethodSafe()) {
                $submitted = (string) $request->header('X-CSRF-TOKEN');
                if ($submitted === '' || ! hash_equals($request->session()->token(), $submitted)) {
                    return response()->json(['success' => false, 'message' => 'Invalid CSRF token.', 'errors' => (object) []], 419);
                }
            }
            $request->setUserResolver(fn () => $user);

            return $next($request);
        }

        $user = User::where('api_token', $token)->where('status', 'active')->first();

        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Invalid or expired token.', 'errors' => (object) []], 401);
        }

        $request->setUserResolver(fn () => $user);

        return $next($request);
    }
}
