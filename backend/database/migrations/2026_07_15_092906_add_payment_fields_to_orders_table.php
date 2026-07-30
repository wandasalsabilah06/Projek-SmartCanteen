<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('payment_method')->default('cash')->after('status'); // cash, transfer, qris
            $table->string('payment_proof')->nullable()->after('payment_method');
            $table->timestamp('payment_verified_at')->nullable()->after('payment_proof');
            $table->unsignedBigInteger('payment_verified_by')->nullable()->after('payment_verified_at');
            $table->text('payment_rejection_reason')->nullable()->after('payment_verified_by');
            
            $table->foreign('payment_verified_by')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['payment_verified_by']);
            $table->dropColumn([
                'payment_method',
                'payment_proof',
                'payment_verified_at',
                'payment_verified_by',
                'payment_rejection_reason'
            ]);
        });
    }
};
