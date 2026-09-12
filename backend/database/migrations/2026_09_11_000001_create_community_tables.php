<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('community_rooms', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('icon_key')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('community_identities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('anonymous_name');
            $table->string('anonymous_code', 64)->unique();
            $table->string('avatar_seed')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
            $table->unique(['user_id', 'is_active']);
        });

        Schema::create('community_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_id')->constrained('community_rooms')->cascadeOnDelete();
            $table->foreignId('community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->foreignId('parent_id')->nullable()->constrained('community_messages')->nullOnDelete();
            $table->text('body');
            $table->string('status')->default('published')->index();
            $table->json('safety_flags_json')->nullable();
            $table->timestamp('edited_at')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('moderation_notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->index(['room_id', 'status', 'created_at']);
            $table->index(['parent_id', 'status', 'created_at']);
        });

        Schema::create('community_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained('community_messages')->cascadeOnDelete();
            $table->foreignId('community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->string('reaction');
            $table->timestamps();
            $table->unique(['message_id', 'community_identity_id', 'reaction']);
        });

        Schema::create('community_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained('community_messages')->cascadeOnDelete();
            $table->foreignId('reporter_community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->foreignId('reported_community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->string('reason')->index();
            $table->text('details')->nullable();
            $table->string('status')->default('open')->index();
            $table->text('moderator_notes')->nullable();
            $table->timestamps();
            $table->unique(['message_id', 'reporter_community_identity_id', 'reason']);
        });

        Schema::create('community_blocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('blocker_community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->foreignId('blocked_community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['blocker_community_identity_id', 'blocked_community_identity_id'], 'community_blocks_unique');
        });
    }

    public function down(): void
    {
        foreach ([
            'community_blocks',
            'community_reports',
            'community_reactions',
            'community_messages',
            'community_identities',
            'community_rooms',
        ] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
