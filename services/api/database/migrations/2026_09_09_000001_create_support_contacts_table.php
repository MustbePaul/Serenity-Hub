<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('support_contacts', function (Blueprint $table) {
            $table->id();
            $table->string('country_code', 2)->index();
            $table->string('country_name');
            $table->string('service_name');
            $table->text('description')->nullable();
            $table->string('phone_number')->nullable();
            $table->string('whatsapp_number')->nullable();
            $table->string('sms_number')->nullable();
            $table->string('website_url')->nullable();
            $table->string('email')->nullable();
            $table->string('availability_text')->nullable();
            $table->boolean('is_emergency_service')->default(false)->index();
            $table->boolean('is_crisis_support')->default(true)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->unsignedInteger('display_order')->default(0);
            $table->timestamps();
            $table->index(['country_code', 'is_active', 'display_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('support_contacts');
    }
};
