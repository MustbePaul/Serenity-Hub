<?php

use App\Http\Controllers\Api\V1\AppContentController;
use App\Http\Controllers\Api\V1\AuthController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'serenity-hub-api',
    ]);
});

Route::prefix('v1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::get('/resource-categories', [AppContentController::class, 'categories']);
    Route::get('/resources', [AppContentController::class, 'resources']);
    Route::get('/resources/{resource}', [AppContentController::class, 'resource']);
    Route::get('/therapists', [AppContentController::class, 'therapists']);
    Route::get('/therapists/{therapist}/availability', [AppContentController::class, 'availability']);

    Route::middleware('api.token')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/home', [AppContentController::class, 'home']);
        Route::get('/bookmarks', [AppContentController::class, 'bookmarks']);
        Route::post('/resources/{resource}/bookmark', [AppContentController::class, 'bookmark']);
        Route::delete('/resources/{resource}/bookmark', [AppContentController::class, 'removeBookmark']);
        Route::post('/appointments', [AppContentController::class, 'book']);
        Route::post('/mood-checkins', [AppContentController::class, 'mood']);
        Route::post('/support-tickets', [AppContentController::class, 'support']);
    });
});
