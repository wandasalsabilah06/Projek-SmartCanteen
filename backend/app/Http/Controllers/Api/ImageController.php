<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Symfony\Component\HttpFoundation\Response;

/**
 * Serve file gambar dari public/uploads/ dengan CORS header yang benar.
 * Dibutuhkan karena php artisan serve tidak menambah CORS header untuk static files.
 *
 * Contoh URL: GET /api/image/uploads/menus/1782875324_02.jpg
 */
class ImageController extends Controller
{
    public function serve(string $path): Response
    {
        // Sanitasi: hanya izinkan path dalam uploads/
        $path = ltrim($path, '/');

        if (!str_starts_with($path, 'uploads/')) {
            abort(403, 'Access denied');
        }

        // Cegah directory traversal
        if (str_contains($path, '..')) {
            abort(403, 'Invalid path');
        }

        $fullPath = public_path($path);

        if (!file_exists($fullPath) || !is_file($fullPath)) {
            abort(404, 'Image not found');
        }

        // Tentukan MIME type berdasarkan ekstensi
        $ext = strtolower(pathinfo($fullPath, PATHINFO_EXTENSION));
        $mimeMap = [
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'jfif' => 'image/jpeg',
            'png'  => 'image/png',
            'gif'  => 'image/gif',
            'webp' => 'image/webp',
            'svg'  => 'image/svg+xml',
        ];
        $mimeType = $mimeMap[$ext] ?? (mime_content_type($fullPath) ?: 'application/octet-stream');

        $content = file_get_contents($fullPath);

        return response($content, 200, [
            'Content-Type'                 => $mimeType,
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Accept',
            'Cache-Control'                => 'public, max-age=86400',
            'Content-Length'               => strlen($content),
        ]);
    }
}
