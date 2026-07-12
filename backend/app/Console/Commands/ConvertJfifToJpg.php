<?php

namespace App\Console\Commands;

use App\Models\Menu;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ConvertJfifToJpg extends Command
{
    protected $signature = 'menu:convert-images';
    protected $description = 'Konversi gambar .jfif ke .jpg dan update database';

    public function handle(): int
    {
        $menus = Menu::whereNotNull('gambar')
            ->where('gambar', 'like', '%.jfif')
            ->get();

        if ($menus->isEmpty()) {
            $this->info('Tidak ada file .jfif yang perlu dikonversi.');
            return 0;
        }

        $this->info("Ditemukan {$menus->count()} file .jfif...");

        foreach ($menus as $menu) {
            $oldPath = public_path($menu->gambar);
            $newGambar = str_replace('.jfif', '.jpg', $menu->gambar);
            $newPath = public_path($newGambar);

            if (! File::exists($oldPath)) {
                $this->warn("File tidak ditemukan: {$oldPath}");
                continue;
            }

            // Copy file dengan nama baru (rename saja, JFIF = JPEG)
            if (File::copy($oldPath, $newPath)) {
                File::delete($oldPath);
                $menu->update(['gambar' => $newGambar]);
                $this->line("  ✓ {$menu->gambar} → {$newGambar}");
            } else {
                $this->error("  ✗ Gagal konversi: {$menu->gambar}");
            }
        }

        $this->info('Selesai!');
        return 0;
    }
}
