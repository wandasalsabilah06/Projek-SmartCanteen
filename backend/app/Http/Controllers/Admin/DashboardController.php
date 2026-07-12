<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Menu;
use App\Models\Category;
use App\Models\Order;

class DashboardController extends Controller
{
    public function index()
    {
        $data = [
            'total_users' => User::count(),
            'total_categories' => Category::count(),
            'total_menus' => Menu::count(),
            'total_orders' => Order::count(),
            'pending_orders' => Order::where('status', 'pending')->count(),
            'recent_orders' => Order::with(['user', 'orderDetails.menu.category'])
                ->latest()
                ->take(10)
                ->get(),
        ];

        return view('admin.dashboard', $data);
    }
}
