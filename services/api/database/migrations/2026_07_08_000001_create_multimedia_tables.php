<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_assets', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('media_type')->index();
            $table->string('file_url');
            $table->string('thumbnail_url')->nullable();
            $table->unsignedInteger('duration_seconds')->nullable();
            $table->string('language')->default('en');
            $table->longText('transcript')->nullable();
            $table->string('storage_disk')->nullable();
            $table->string('status')->default('published')->index();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['media_type', 'status']);
        });

        Schema::create('resource_media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('resource_id')->constrained()->cascadeOnDelete();
            $table->foreignId('media_asset_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
            $table->unique(['resource_id', 'media_asset_id']);
        });

        Schema::create('wellness_sessions', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('category')->index();
            $table->string('target_mood')->nullable()->index();
            $table->string('difficulty')->default('beginner');
            $table->unsignedInteger('estimated_duration_seconds')->nullable();
            $table->foreignId('resource_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('media_asset_id')->constrained()->cascadeOnDelete();
            $table->boolean('is_featured')->default(false)->index();
            $table->string('status')->default('published')->index();
            $table->timestamps();
            $table->index(['category', 'status', 'is_featured']);
        });

        Schema::create('user_media_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('media_asset_id')->constrained()->cascadeOnDelete();
            $table->foreignId('resource_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('wellness_session_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedInteger('progress_seconds')->default(0);
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->float('progress_percent')->default(0);
            $table->boolean('is_completed')->default(false)->index();
            $table->timestamp('last_played_at')->nullable()->index();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'media_asset_id', 'wellness_session_id'], 'user_media_session_unique');
            $table->index(['user_id', 'is_completed', 'last_played_at']);
        });
    }

    public function down(): void
    {
        foreach ([
            'user_media_progress',
            'wellness_sessions',
            'resource_media',
            'media_assets',
        ] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
