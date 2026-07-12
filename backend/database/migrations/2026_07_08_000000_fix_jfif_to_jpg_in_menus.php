<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Ganti semua path .jfif menjadi .jpg di kolom gambar
        DB::table('menus')
            ->where('gambar', 'like', '%.jfif')
            ->get()
            ->each(function ($menu) {
                DB::table('menus')
                    ->where('id', $menu->id)
                    ->update([
                        'gambar' => str_replace('.jfif', '.jpg', $menu->gambar),
                    ]);
            });
    }

    public function down(): void
    {
        // Kembalikan .jpg ke .jfif jika perlu rollback
        DB::table('menus')
            ->where('gambar', 'like', '%.jpg')
            ->where('gambar', 'like', '%uploads/menus/%')
            ->get()
            ->each(function ($menu) {
                // Hanya rollback file yang sebelumnya adalah .jfif
                // (file asli masih ada sebagai .jfif)
                $jfifPath = str_replace('.jpg', '.jfif', $menu->gambar);
                if (file_exists(public_path($jfifPath))) {
                    DB::table('menus')
                        ->where('id', $menu->id)
                        ->update(['gambar' => $jfifPath]);
                }
            });
    }
};
