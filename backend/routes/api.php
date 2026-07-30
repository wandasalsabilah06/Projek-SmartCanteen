<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ImageController;

// ── Auth ─────────────────────────────────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ── Menu ─────────────────────────────────────────────────────────────────────
Route::get('/menus',      [MenuController::class, 'index']);
Route::get('/menus/{id}', [MenuController::class, 'show']);

// ── Orders ───────────────────────────────────────────────────────────────────
Route::post('/orders',                              [OrderController::class, 'store']);
Route::get('/orders/user/{userId}',                 [OrderController::class, 'userOrders']);
Route::get('/orders/{id}',                          [OrderController::class, 'show']);
Route::post('/orders/{id}/upload-payment-proof',    [OrderController::class, 'uploadPaymentProof']);
Route::post('/orders/{id}/confirm-collected',       [OrderController::class, 'confirmCollected']);

// ── Image proxy — serve gambar dengan CORS header ────────────────────────────
// Flutter Web memanggil: GET /api/image/uploads/menus/xxx.jpg
Route::get('/image/{path}', [ImageController::class, 'serve'])
    ->where('path', '.*');
