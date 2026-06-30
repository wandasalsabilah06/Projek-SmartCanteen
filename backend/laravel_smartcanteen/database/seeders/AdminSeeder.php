<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Category;
use App\Models\Menu;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin',
            'email' => 'admin@admin.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        // Create sample user
        User::create([
            'name' => 'User Test',
            'email' => 'user@test.com',
            'password' => Hash::make('password'),
            'role' => 'pelanggan',
        ]);

        // Create categories
        $categories = [
            ['nama' => 'Makanan', 'target' => 10],
            ['nama' => 'Minuman', 'target' => 8],
            ['nama' => 'Snack', 'target' => 5],
            ['nama' => 'Dessert', 'target' => 5],
        ];

        foreach ($categories as $cat) {
            Category::create([
                'nama_kategori' => $cat['nama'],
                'target_jumlah_menu' => $cat['target'],
            ]);
        }

        // Create sample menus
        Menu::create([
            'category_id' => 1,
            'nama_menu' => 'Nasi Goreng',
            'harga' => 15000,
            'stok' => 20,
            'deskripsi' => 'Nasi goreng spesial dengan telur',
        ]);

        Menu::create([
            'category_id' => 1,
            'nama_menu' => 'Mie Ayam',
            'harga' => 12000,
            'stok' => 15,
            'deskripsi' => 'Mie ayam dengan topping ayam suwir',
        ]);

        Menu::create([
            'category_id' => 2,
            'nama_menu' => 'Es Teh Manis',
            'harga' => 5000,
            'stok' => 50,
            'deskripsi' => 'Es teh manis segar',
        ]);

        Menu::create([
            'category_id' => 2,
            'nama_menu' => 'Jus Jeruk',
            'harga' => 8000,
            'stok' => 30,
            'deskripsi' => 'Jus jeruk segar tanpa gula',
        ]);
    }
}
