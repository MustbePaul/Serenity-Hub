<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('community_messages', function (Blueprint $table) {
            $table->index(['room_id', 'status', 'id'], 'community_messages_room_status_id_index');
            $table->index(['community_identity_id', 'status'], 'community_messages_identity_status_index');
        });

        Schema::table('community_reactions', function (Blueprint $table) {
            $table->index(['community_identity_id', 'message_id'], 'community_reactions_identity_message_index');
        });

        Schema::table('community_reports', function (Blueprint $table) {
            $table->index(['status', 'created_at'], 'community_reports_status_created_at_index');
        });

        Schema::table('community_blocks', function (Blueprint $table) {
            $table->index('blocked_community_identity_id', 'community_blocks_blocked_identity_index');
        });

        Schema::create('community_posting_restrictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('community_identity_id')->constrained('community_identities')->cascadeOnDelete();
            $table->string('state')->index();
            $table->text('reason')->nullable();
            $table->foreignId('applied_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('starts_at')->useCurrent();
            $table->timestamp('expires_at')->nullable()->index();
            $table->timestamp('removed_at')->nullable()->index();
            $table->foreignId('removed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['community_identity_id', 'removed_at', 'expires_at'], 'community_restrictions_active_index');
        });

        Schema::create('community_moderation_audits', function (Blueprint $table) {
            $table->id();
            $table->string('action')->index();
            $table->foreignId('actor_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('community_message_id')->nullable()->constrained('community_messages')->nullOnDelete();
            $table->foreignId('community_report_id')->nullable()->constrained('community_reports')->nullOnDelete();
            $table->foreignId('community_identity_id')->nullable()->constrained('community_identities')->nullOnDelete();
            $table->json('metadata')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('community_moderation_audits');
        Schema::dropIfExists('community_posting_restrictions');

        if (Schema::hasTable('community_blocks')) {
            Schema::table('community_blocks', function (Blueprint $table) {
                $table->dropIndex('community_blocks_blocked_identity_index');
            });
        }

        if (Schema::hasTable('community_reports')) {
            Schema::table('community_reports', function (Blueprint $table) {
                $table->dropIndex('community_reports_status_created_at_index');
            });
        }

        if (Schema::hasTable('community_reactions')) {
            Schema::table('community_reactions', function (Blueprint $table) {
                $table->dropIndex('community_reactions_identity_message_index');
            });
        }

        if (Schema::hasTable('community_messages')) {
            Schema::table('community_messages', function (Blueprint $table) {
                $table->dropIndex('community_messages_room_status_id_index');
                $table->dropIndex('community_messages_identity_status_index');
            });
        }
    }
};
