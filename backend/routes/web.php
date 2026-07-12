<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController as AdminUserController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\MenuController as AdminMenuController;
use App\Http\Controllers\Admin\OrderController as AdminOrderController;

Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});

Route::get('/tes', function () {
    return 'Berhasil';
});

Route::resource('users', UserController::class);

// Admin Routes
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    Route::resource('users', AdminUserController::class);
    Route::resource('categories', CategoryController::class);
    Route::resource('menus', AdminMenuController::class);
    
    Route::resource('orders', AdminOrderController::class)->only(['index', 'show', 'create', 'store', 'destroy']);
    Route::patch('orders/{order}/status', [AdminOrderController::class, 'updateStatus'])->name('orders.updateStatus');
    
    // Order Details
    Route::get('orders/{order}/details/create', [\App\Http\Controllers\Admin\OrderDetailController::class, 'create'])->name('orders.details.create');
    Route::post('orders/{order}/details', [\App\Http\Controllers\Admin\OrderDetailController::class, 'store'])->name('orders.details.store');
    Route::delete('orders/{order}/details/{orderDetail}', [\App\Http\Controllers\Admin\OrderDetailController::class, 'destroy'])->name('orders.details.destroy');
});