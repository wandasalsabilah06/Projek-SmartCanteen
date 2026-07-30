<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Untuk MySQL: ALTER TABLE dengan MODIFY COLUMN
        DB::statement("ALTER TABLE orders MODIFY COLUMN status ENUM('pending', 'diproses', 'selesai', 'diambil', 'dibatalkan') DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Kembalikan ke ENUM semula (tanpa 'diambil')
        DB::statement("ALTER TABLE orders MODIFY COLUMN status ENUM('pending', 'diproses', 'selesai', 'dibatalkan') DEFAULT 'pending'");
    }
};
