<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\Order;
use App\Models\OrderDetail;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * GET /api/orders/user/{userId}
     * Ambil semua order milik user tertentu beserta detail menu.
     */
    public function userOrders(int $userId)
    {
        $orders = Order::with(['orderDetails.menu.category'])
            ->where('user_id', $userId)
            ->latest()
            ->get();

        return response()->json($orders);
    }

    /**
     * POST /api/orders
     * Buat order baru beserta detail item.
     */
    public function store(Request $request)
    {
        $request->validate([
            'user_id'              => 'required|exists:users,id',
            'total_harga'          => 'required|numeric|min:0',
            'payment_method'       => 'nullable|in:cash,transfer,qris',
            'items'                => 'required|array|min:1',
            'items.*.menu_id'      => 'required|exists:menus,id',
            'items.*.qty'          => 'required|integer|min:1',
            'items.*.harga'        => 'required|numeric|min:0',
            'items.*.subtotal'     => 'required|numeric|min:0',
        ]);

        // Cek stok semua item sebelum membuat order
        foreach ($request->items as $item) {
            $menu = Menu::find($item['menu_id']);
            if (!$menu) {
                return response()->json([
                    'message' => "Menu tidak ditemukan (ID: {$item['menu_id']})",
                ], 422);
            }
            if ($menu->stok < $item['qty']) {
                return response()->json([
                    'message' => "Stok {$menu->nama_menu} tidak cukup. Tersisa: {$menu->stok}",
                ], 422);
            }
        }

        // Buat order
        $order = Order::create([
            'user_id'        => $request->user_id,
            'tanggal_order'  => now()->toDateString(),
            'total_harga'    => $request->total_harga,
            'status'         => 'pending',
            'payment_method' => $request->payment_method ?? 'cash',
        ]);

        // Buat detail & kurangi stok
        foreach ($request->items as $item) {
            OrderDetail::create([
                'order_id' => $order->id,
                'menu_id'  => $item['menu_id'],
                'qty'      => $item['qty'],
                'harga'    => $item['harga'],
                'subtotal' => $item['subtotal'],
            ]);

            // Kurangi stok
            Menu::where('id', $item['menu_id'])
                ->decrement('stok', $item['qty']);
        }

        // Return order dengan relasi lengkap
        $order->load(['orderDetails.menu.category', 'user']);

        return response()->json([
            'message' => 'Order berhasil dibuat',
            'order'   => $order,
        ], 201);
    }

    /**
     * POST /api/orders/{id}/upload-payment-proof
     * Upload bukti transfer pembayaran
     */
    public function uploadPaymentProof(Request $request, $id)
    {
        $request->validate([
            'payment_proof' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $order = Order::findOrFail($id);

        // Validasi: hanya untuk metode transfer
        if ($order->payment_method !== 'transfer') {
            return response()->json([
                'message' => 'Upload bukti hanya untuk metode transfer',
            ], 422);
        }

        // Hapus file lama jika ada
        if ($order->payment_proof && \Storage::disk('public')->exists($order->payment_proof)) {
            \Storage::disk('public')->delete($order->payment_proof);
        }

        // Upload file baru
        $file = $request->file('payment_proof');
        $path = $file->store('payment_proofs', 'public');

        // Reset verification jika upload ulang
        $order->update([
            'payment_proof' => $path,
            'payment_verified_at' => null,
            'payment_verified_by' => null,
            'payment_rejection_reason' => null,
        ]);

        return response()->json([
            'message' => 'Bukti transfer berhasil diupload',
            'payment_proof_url' => $order->payment_proof_url,
        ]);
    }

    /**
     * GET /api/orders/{id}
     * Detail order dengan info pembayaran
     */
    public function show($id)
    {
        $order = Order::with([
            'orderDetails.menu.category',
            'user',
            'verifiedBy'
        ])->findOrFail($id);

        return response()->json($order);
    }

    /**
     * POST /api/orders/{id}/confirm-collected
     * Konfirmasi pesanan sudah diambil oleh user
     */
    public function confirmCollected($id)
    {
        $order = Order::findOrFail($id);

        // Validasi: hanya order dengan status 'selesai' yang bisa dikonfirmasi
        if ($order->status !== 'selesai') {
            return response()->json([
                'message' => 'Hanya pesanan dengan status "Selesai" yang dapat dikonfirmasi pengambilannya',
            ], 422);
        }

        // Update status menjadi 'diambil'
        $order->update([
            'status' => 'diambil',
        ]);

        // Return order dengan relasi lengkap
        $order->load(['orderDetails.menu.category', 'user', 'verifiedBy']);

        return response()->json([
            'message' => 'Pesanan berhasil dikonfirmasi sebagai telah diambil',
            'order' => $order,
        ]);
    }
}
