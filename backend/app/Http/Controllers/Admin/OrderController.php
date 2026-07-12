<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index()
    {
        $orders = Order::with(['user', 'orderDetails.menu'])
            ->latest()
            ->paginate(10);
        return view('admin.orders.index', compact('orders'));
    }

    public function create()
    {
        $users = User::all();
        return view('admin.orders.create', compact('users'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'status' => 'required|in:pending,diproses,selesai,dibatalkan',
        ]);

        $order = Order::create([
            'user_id' => $request->user_id,
            'tanggal_order' => now(),
            'total_harga' => 0,
            'status' => $request->status,
        ]);

        return redirect()->route('admin.orders.show', $order)
            ->with('success', 'Order berhasil dibuat. Silakan tambahkan item.');
    }

    public function show(Order $order)
    {
        $order->load(['user', 'orderDetails.menu.category']);
        return view('admin.orders.show', compact('order'));
    }

    public function updateStatus(Request $request, Order $order)
    {
        $request->validate([
            'status' => 'required|in:pending,diproses,selesai,dibatalkan',
        ]);

        $order->update(['status' => $request->status]);
        return redirect()->back()->with('success', 'Status order berhasil diupdate');
    }

    public function destroy(Order $order)
    {
        $order->delete();
        return redirect()->route('admin.orders.index')->with('success', 'Order berhasil dihapus');
    }
}
