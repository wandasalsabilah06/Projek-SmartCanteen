<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderDetail;
use App\Models\Menu;
use Illuminate\Http\Request;

class OrderDetailController extends Controller
{
    public function create(Order $order)
    {
        $menus = Menu::where('stok', '>', 0)->get();
        return view('admin.order-details.create', compact('order', 'menus'));
    }

    public function store(Request $request, Order $order)
    {
        $request->validate([
            'menu_id' => 'required|exists:menus,id',
            'qty' => 'required|integer|min:1',
        ]);

        $menu = Menu::findOrFail($request->menu_id);

        // Check stok
        if ($menu->stok < $request->qty) {
            return back()->with('error', 'Stok tidak mencukupi');
        }

        $subtotal = $menu->harga * $request->qty;

        OrderDetail::create([
            'order_id' => $order->id,
            'menu_id' => $request->menu_id,
            'qty' => $request->qty,
            'harga' => $menu->harga,
            'subtotal' => $subtotal,
        ]);

        // Update total harga order
        $order->total_harga = $order->orderDetails()->sum('subtotal');
        $order->save();

        // Kurangi stok
        $menu->decrement('stok', $request->qty);

        return redirect()->route('admin.orders.show', $order)
            ->with('success', 'Item berhasil ditambahkan ke order');
    }

    public function destroy(Order $order, OrderDetail $orderDetail)
    {
        // Kembalikan stok
        $orderDetail->menu->increment('stok', $orderDetail->qty);

        // Hapus detail
        $orderDetail->delete();

        // Update total harga order
        $order->total_harga = $order->orderDetails()->sum('subtotal');
        $order->save();

        return redirect()->route('admin.orders.show', $order)
            ->with('success', 'Item berhasil dihapus dari order');
    }
}
