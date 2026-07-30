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
            'status' => 'required|in:pending,diproses,selesai,diambil,dibatalkan',
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
        $order->load(['user', 'orderDetails.menu.category', 'verifiedBy']);
        return view('admin.orders.show', compact('order'));
    }

    public function verifyPayment(Request $request, Order $order)
    {
        if ($order->payment_method !== 'transfer') {
            return redirect()->back()->with('error', 'Hanya untuk metode transfer');
        }

        $order->update([
            'payment_verified_at' => now(),
            'payment_verified_by' => auth()->id(),
            'payment_rejection_reason' => null,
        ]);

        return redirect()->back()->with('success', 'Pembayaran berhasil diverifikasi');
    }

    public function rejectPayment(Request $request, Order $order)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        if ($order->payment_method !== 'transfer') {
            return redirect()->back()->with('error', 'Hanya untuk metode transfer');
        }

        $order->update([
            'payment_verified_at' => null,
            'payment_verified_by' => null,
            'payment_rejection_reason' => $request->rejection_reason,
        ]);

        return redirect()->back()->with('success', 'Pembayaran ditolak');
    }

    public function updateStatus(Request $request, Order $order)
    {
        $request->validate([
            'status' => 'required|in:pending,diproses,selesai,diambil,dibatalkan',
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
