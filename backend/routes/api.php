<?php

use App\Http\Controllers\Api\V1\AppContentController;
use App\Http\Controllers\Api\V1\AppointmentController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CommunityBroadcastAuthController;
use App\Http\Controllers\Api\V1\CommunityController;
use App\Http\Controllers\Api\V1\CommunityModerationController;
use App\Http\Controllers\Api\V1\MediaController;
use App\Http\Controllers\Api\V1\MediaProgressController;
use App\Http\Controllers\Api\V1\RecommendationController;
use App\Http\Controllers\Api\V1\SupportContactController;
use App\Http\Controllers\Api\V1\WellnessSessionController;
use App\Http\Controllers\UssdController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'serenity-hub-api',
    ]);
});

// Provider-agnostic prototype callback. Configure an approved aggregator to POST
// sessionId, serviceCode, phoneNumber, and text here after shortcode provisioning.
Route::post('/ussd', [UssdController::class, 'handle']);

Route::prefix('v1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::get('/resource-categories', [AppContentController::class, 'categories']);
    Route::get('/resources', [AppContentController::class, 'resources']);
    Route::get('/resources/{resource}', [AppContentController::class, 'resource']);
    Route::get('/media', [MediaController::class, 'index']);
    Route::get('/media/{media}', [MediaController::class, 'show']);
    Route::get('/wellness-sessions', [WellnessSessionController::class, 'index']);
    Route::get('/wellness-sessions/{session}', [WellnessSessionController::class, 'show']);
    Route::get('/support-contacts', [SupportContactController::class, 'index']);
    Route::get('/support-contacts/{supportContact}', [SupportContactController::class, 'show']);
    Route::get('/therapists', [AppContentController::class, 'therapists']);
    Route::get('/therapists/{therapist}/availability', [AppContentController::class, 'availability']);

    Route::middleware('api.token')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/home', [AppContentController::class, 'home']);
        Route::get('/appointments', [AppContentController::class, 'appointments']);
        Route::get('/appointments/{appointment}', [AppointmentController::class, 'show']);
        Route::patch('/profile', [AppContentController::class, 'updateProfile']);
        Route::get('/bookmarks', [AppContentController::class, 'bookmarks']);
        Route::post('/resources/{resource}/bookmark', [AppContentController::class, 'bookmark']);
        Route::delete('/resources/{resource}/bookmark', [AppContentController::class, 'removeBookmark']);
        Route::post('/media/{media}/progress', [MediaProgressController::class, 'store']);
        Route::get('/me/media-progress', [MediaProgressController::class, 'index']);
        Route::get('/me/recommendations', [RecommendationController::class, 'index']);
        Route::post('/appointments', [AppContentController::class, 'book']);
        Route::patch('/appointments/{appointment}/reschedule', [AppointmentController::class, 'reschedule']);
        Route::patch('/appointments/{appointment}/cancel', [AppointmentController::class, 'cancel']);
        Route::post('/mood-checkins', [AppContentController::class, 'mood']);
        Route::post('/support-tickets', [AppContentController::class, 'support']);

        Route::get('/community/me', [CommunityController::class, 'me']);
        Route::post('/community/broadcasting/auth', CommunityBroadcastAuthController::class);
        Route::get('/community/rooms', [CommunityController::class, 'rooms']);
        Route::get('/community/rooms/{room:slug}/messages', [CommunityController::class, 'messages']);
        Route::post('/community/rooms/{room:slug}/messages', [CommunityController::class, 'storeMessage'])->middleware('throttle:community-posts');
        Route::get('/community/messages/{message}/replies', [CommunityController::class, 'replies']);
        Route::post('/community/messages/{message}/replies', [CommunityController::class, 'storeReply'])->middleware('throttle:community-posts');
        Route::post('/community/messages/{message}/reactions', [CommunityController::class, 'react'])->middleware('throttle:community-reactions');
        Route::delete('/community/messages/{message}/reactions/{reaction}', [CommunityController::class, 'removeReaction'])->middleware('throttle:community-reactions');
        Route::post('/community/messages/{message}/report', [CommunityController::class, 'report'])->middleware('throttle:community-reports');
        Route::post('/community/identities/{identity}/block', [CommunityController::class, 'block']);
        Route::delete('/community/identities/{identity}/block', [CommunityController::class, 'unblock']);
        Route::delete('/community/messages/{message}', [CommunityController::class, 'destroy']);

        Route::prefix('/community/moderation')->middleware('community.moderator')->group(function () {
            Route::get('/reports', [CommunityModerationController::class, 'reports']);
            Route::get('/reports/{report}', [CommunityModerationController::class, 'report']);
            Route::patch('/reports/{report}', [CommunityModerationController::class, 'updateReport']);
            Route::patch('/messages/{message}/hide', [CommunityModerationController::class, 'hideMessage']);
            Route::patch('/messages/{message}/restore', [CommunityModerationController::class, 'restoreMessage']);
            Route::patch('/messages/{message}/remove', [CommunityModerationController::class, 'removeMessage']);
            Route::post('/identities/{identity}/restriction', [CommunityModerationController::class, 'restrictPosting']);
            Route::delete('/identities/{identity}/restriction', [CommunityModerationController::class, 'restorePosting']);
        });
    });
});
