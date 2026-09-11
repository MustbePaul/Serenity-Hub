<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wellness_sessions', function (Blueprint $table) {
            $table->string('session_type')->nullable()->after('category')->index();
            $table->longText('instructions')->nullable()->after('description');
            $table->longText('transcript')->nullable()->after('instructions');
            $table->string('breathing_pattern')->nullable()->after('transcript');
            $table->unsignedTinyInteger('inhale_seconds')->nullable()->after('breathing_pattern');
            $table->unsignedTinyInteger('hold_seconds')->nullable()->after('inhale_seconds');
            $table->unsignedTinyInteger('exhale_seconds')->nullable()->after('hold_seconds');
            $table->unsignedTinyInteger('second_hold_seconds')->nullable()->after('exhale_seconds');
            $table->foreignId('background_audio_media_id')->nullable()->after('media_asset_id')->constrained('media_assets')->nullOnDelete();
            $table->foreignId('narration_media_id')->nullable()->after('background_audio_media_id')->constrained('media_assets')->nullOnDelete();
            $table->foreignId('demonstration_video_media_id')->nullable()->after('narration_media_id')->constrained('media_assets')->nullOnDelete();
            $table->boolean('supports_offline')->default(false)->after('is_featured');
        });
    }

    public function down(): void
    {
        Schema::table('wellness_sessions', function (Blueprint $table) {
            $table->dropConstrainedForeignId('demonstration_video_media_id');
            $table->dropConstrainedForeignId('narration_media_id');
            $table->dropConstrainedForeignId('background_audio_media_id');
            $table->dropColumn([
                'session_type',
                'instructions',
                'transcript',
                'breathing_pattern',
                'inhale_seconds',
                'hold_seconds',
                'exhale_seconds',
                'second_hold_seconds',
                'supports_offline',
            ]);
        });
    }
};
