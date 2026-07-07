<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('phone')->nullable();
            $table->string('gender')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->string('emergency_contact_name')->nullable();
            $table->string('emergency_contact_phone')->nullable();
            $table->string('avatar_url')->nullable();
            $table->timestamp('privacy_consent_at')->nullable();
            $table->timestamps();
        });

        Schema::create('user_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->boolean('daily_reminders')->default(true);
            $table->time('reminder_time')->nullable();
            $table->json('notification_channels')->nullable();
            $table->string('theme_mode')->default('system');
            $table->json('privacy_options_json')->nullable();
            $table->timestamps();
        });

        Schema::create('therapist_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('license_number')->unique();
            $table->text('qualifications')->nullable();
            $table->text('bio')->nullable();
            $table->string('location')->nullable();
            $table->unsignedInteger('consultation_fee')->default(0);
            $table->json('session_modes')->nullable();
            $table->string('verification_status')->default('pending')->index();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
        });

        Schema::create('specialties', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->timestamps();
        });

        Schema::create('therapist_specialties', function (Blueprint $table) {
            $table->foreignId('therapist_id')->constrained('therapist_profiles')->cascadeOnDelete();
            $table->foreignId('specialty_id')->constrained()->cascadeOnDelete();
            $table->primary(['therapist_id', 'specialty_id']);
        });

        Schema::create('availability_slots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained('therapist_profiles')->cascadeOnDelete();
            $table->dateTime('starts_at');
            $table->dateTime('ends_at');
            $table->string('status')->default('available')->index();
            $table->string('timezone')->default('Africa/Blantyre');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['therapist_id', 'starts_at', 'status']);
        });

        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('therapist_id')->constrained('therapist_profiles')->cascadeOnDelete();
            $table->foreignId('availability_slot_id')->nullable()->unique()->constrained()->nullOnDelete();
            $table->dateTime('scheduled_start');
            $table->dateTime('scheduled_end');
            $table->string('mode');
            $table->string('location_or_link')->nullable();
            $table->text('reason')->nullable();
            $table->string('status')->default('confirmed')->index();
            $table->timestamps();
            $table->index(['user_id', 'status', 'scheduled_start']);
            $table->index(['therapist_id', 'status', 'scheduled_start']);
        });

        Schema::create('session_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('appointment_id')->constrained()->cascadeOnDelete();
            $table->foreignId('therapist_id')->constrained('therapist_profiles')->cascadeOnDelete();
            $table->text('private_note');
            $table->timestamps();
        });

        Schema::create('resource_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->unsignedInteger('display_order')->default(0);
            $table->timestamps();
        });

        Schema::create('resources', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('resource_categories')->cascadeOnDelete();
            $table->string('title');
            $table->string('slug')->unique();
            $table->string('type')->default('article');
            $table->text('summary');
            $table->longText('body');
            $table->string('content_url')->nullable();
            $table->json('tags')->nullable();
            $table->string('status')->default('draft')->index();
            $table->timestamp('published_at')->nullable()->index();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['category_id', 'status', 'published_at']);
            $table->index('title');
        });

        Schema::create('bookmarks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('resource_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['user_id', 'resource_id']);
        });

        Schema::create('quotes_affirmations', function (Blueprint $table) {
            $table->id();
            $table->text('text');
            $table->string('author')->nullable();
            $table->string('theme')->nullable();
            $table->string('type')->default('quote');
            $table->boolean('active')->default(true)->index();
            $table->date('display_date')->nullable()->index();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('mood_checkins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('mood_score');
            $table->json('tags')->nullable();
            $table->text('note')->nullable();
            $table->timestamp('checked_in_at')->useCurrent();
            $table->timestamps();
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('message');
            $table->string('type')->default('system');
            $table->json('data_json')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });

        Schema::create('support_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('subject');
            $table->text('message');
            $table->string('status')->default('open')->index();
            $table->string('priority')->default('normal')->index();
            $table->foreignId('assigned_to')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'status', 'priority']);
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('actor_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('action')->index();
            $table->string('entity_type')->nullable();
            $table->unsignedBigInteger('entity_id')->nullable();
            $table->json('old_values_json')->nullable();
            $table->json('new_values_json')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        foreach ([
            'audit_logs',
            'support_tickets',
            'notifications',
            'mood_checkins',
            'quotes_affirmations',
            'bookmarks',
            'resources',
            'resource_categories',
            'session_notes',
            'appointments',
            'availability_slots',
            'therapist_specialties',
            'specialties',
            'therapist_profiles',
            'user_settings',
            'user_profiles',
        ] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
