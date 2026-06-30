<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderDetail;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $order = Order::create([
            'user_id' => $request->user_id,
            'tanggal_order' => now(),
            'total_harga' => $request->total_harga,
            'status' => 'pending'
        ]);

        foreach ($request->items as $item)
        {
            OrderDetail::create([
                'order_id' => $order->id,
                'menu_id' => $item['menu_id'],
                'qty' => $item['qty'],
                'harga' => $item['harga'],
                'subtotal' => $item['subtotal']
            ]);
        }

        return response()->json([
            'message' => 'Order berhasil disimpan',
            'order' => $order
        ]);
    }
}