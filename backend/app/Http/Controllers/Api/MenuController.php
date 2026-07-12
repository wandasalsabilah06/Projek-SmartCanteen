<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;

class MenuController extends Controller
{
    public function index()
    {
        $menus = Menu::with('category')->get();

        // Tambahkan gambar_url = full URL via /api/image/...
        $menus->transform(fn ($menu) => $this->appendGambarUrl($menu));

        return response()->json($menus);
    }

    public function show($id)
    {
        $menu = Menu::with('category')->findOrFail($id);
        $this->appendGambarUrl($menu);
        return response()->json($menu);
    }

    /**
     * Tambahkan atribut gambar_url ke model menu.
     * URL diarahkan ke endpoint /api/image/ agar Flutter Web mendapat CORS header.
     */
    private function appendGambarUrl(Menu $menu): Menu
    {
        if (empty($menu->gambar)) {
            $menu->gambar_url = null;
        } else {
            // Buat URL via /api/image/ bukan langsung ke /uploads/
            // sehingga CORS header selalu ada
            $menu->gambar_url = url('/api/image/' . ltrim($menu->gambar, '/'));
        }
        return $menu;
    }
}
