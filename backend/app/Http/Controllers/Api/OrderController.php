<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderDetail;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * Get orders for a specific user
     */
    public function userOrders($userId)
    {
        $orders = Order::with(['orderDetails.menu.category'])
            ->where('user_id', $userId)
            ->latest()
            ->get();

        return response()->json($orders);
    }

    /**
     * Store a new order with its details
     */
    public function store(Request $request)
    {
        $request->validate([
            'user_id'     => 'required|exists:users,id',
            'total_harga' => 'required|numeric|min:0',
            'items'       => 'required|array|min:1',
            'items.*.menu_id'  => 'required|exists:menus,id',
            'items.*.qty'      => 'required|integer|min:1',
            'items.*.harga'    => 'required|numeric|min:0',
            'items.*.subtotal' => 'required|numeric|min:0',
        ]);

        $order = Order::create([
            'user_id'      => $request->user_id,
            'tanggal_order' => now(),
            'total_harga'  => $request->total_harga,
            'status'       => 'pending',
        ]);

        foreach ($request->items as $item) {
            OrderDetail::create([
                'order_id' => $order->id,
                'menu_id'  => $item['menu_id'],
                'qty'      => $item['qty'],
                'harga'    => $item['harga'],
                'subtotal' => $item['subtotal'],
            ]);
        }

        // Return with relations loaded
        $order->load(['orderDetails.menu.category', 'user']);

        return response()->json([
            'message' => 'Order berhasil disimpan',
            'order'   => $order,
        ], 201);
    }
}
