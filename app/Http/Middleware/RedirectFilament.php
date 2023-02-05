<?php

namespace App\Http\Middleware;

use Closure;
use Filament\Models\Contracts\FilamentUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RedirectFilament
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();
 
        if ($user instanceof FilamentUser) {
            if (! $user->canAccessFilament()) {
                return redirect()->route('computers.index');
            }
        }
    
        return $next($request);
    }
}
