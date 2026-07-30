<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;

class MenuController extends Controller
{
    public function index()
    {
        $menus = Menu::with('category')->get();
        $menus->transform(fn ($m) => $this->withImageUrl($m));
        return response()->json($menus);
    }

    public function show($id)
    {
        $menu = Menu::with('category')->findOrFail($id);
        $this->withImageUrl($menu);
        return response()->json($menu);
    }

    /**
     * Tambahkan gambar_url ke menu — arahkan ke /api/image/ agar dapat CORS header.
     * APP_URL wajib di-set ke http://192.168.100.163:8000 di .env
     * agar URL valid dari device fisik.
     */
    private function withImageUrl(Menu $menu): Menu
    {
        if (empty($menu->gambar)) {
            $menu->gambar_url = null;
        } else {
            // url() akan pakai APP_URL dari .env
            $menu->gambar_url = url('/api/image/' . ltrim($menu->gambar, '/'));
        }
        return $menu;
    }
}
