<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BrowserAuthController;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('web')->group(function () {
    Route::get('/csrf', [BrowserAuthController::class, 'csrf']);
    Route::post('/login', [BrowserAuthController::class, 'login'])->middleware('throttle:10,1');
    Route::post('/register', [BrowserAuthController::class, 'register'])->middleware('throttle:6,1');
    Route::get('/me', [BrowserAuthController::class, 'me']);
    Route::post('/logout', [BrowserAuthController::class, 'logout']);
});
