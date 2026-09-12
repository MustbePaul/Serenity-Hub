<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CommunityModerator
{
    public function handle(Request $request, Closure $next)
    {
        $role = $request->user()?->role;

        if (! in_array($role, ['admin', 'moderator'], true)) {
            return response()->json(['success' => false, 'message' => 'Forbidden.', 'errors' => (object) []], 403);
        }

        return $next($request);
    }
}
