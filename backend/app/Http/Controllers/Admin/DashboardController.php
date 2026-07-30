<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Menu;
use App\Models\Category;
use App\Models\Order;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        // Total pengguna (kecuali admin)
        $total_users = User::where('role', '!=', 'admin')->count();
        
        // Pembayaran pending - SEMUA metode pembayaran yang statusnya pending
        // Menampilkan semua order dengan status 'pending' dari metode apapun
        $pending_payments = Order::where('status', 'pending')
            ->with(['user'])
            ->orderByDesc('total_harga')
            ->get();
        
        // 4 Statistik pembayaran pending
        // 1. Total amount yang masih pending (menunggu verifikasi)
        $total_pending_amount = Order::where('payment_method', 'transfer')
            ->whereNotNull('payment_proof')
            ->whereNull('payment_verified_at')
            ->whereNull('payment_rejection_reason')
            ->sum('total_harga');
        
        // 2. Total count pembayaran pending
        $total_pending_count = Order::where('payment_method', 'transfer')
            ->whereNotNull('payment_proof')
            ->whereNull('payment_verified_at')
            ->whereNull('payment_rejection_reason')
            ->count();
        
        // 3. Total pembayaran yang belum upload bukti
        $belum_upload_count = Order::where('payment_method', 'transfer')
            ->whereNull('payment_proof')
            ->count();
        
        $belum_upload_amount = Order::where('payment_method', 'transfer')
            ->whereNull('payment_proof')
            ->sum('total_harga');
        
        // 4. Total pembayaran yang ditolak
        $ditolak_count = Order::where('payment_method', 'transfer')
            ->whereNotNull('payment_rejection_reason')
            ->count();
        
        $ditolak_amount = Order::where('payment_method', 'transfer')
            ->whereNotNull('payment_rejection_reason')
            ->sum('total_harga');
        
        // Total menu
        $total_menus = Menu::count();
        
        // Total orders
        $total_orders = Order::count();
        
        // Pendapatan bulanan (Jan - Des tahun ini)
        // Menghitung SEMUA metode pembayaran:
        // - Cash/QRIS: langsung dihitung (tidak perlu verifikasi)
        // - Transfer: hanya yang terverifikasi
        $monthly_revenue = [];
        $year = Carbon::now()->year;
        
        for ($month = 1; $month <= 12; $month++) {
            $revenue = Order::whereYear('tanggal_order', $year)
                ->whereMonth('tanggal_order', $month)
                ->whereIn('status', ['diproses', 'selesai', 'diambil'])
                ->where(function($query) {
                    // Cash atau QRIS (tidak perlu verifikasi)
                    $query->whereIn('payment_method', ['cash', 'qris'])
                        // ATAU transfer yang sudah terverifikasi
                        ->orWhere(function($q) {
                            $q->where('payment_method', 'transfer')
                              ->whereNotNull('payment_verified_at');
                        });
                })
                ->sum('total_harga');
            
            $monthly_revenue[] = [
                'month' => $month,
                'month_name' => Carbon::create($year, $month, 1)->format('M'),
                'revenue' => $revenue
            ];
        }
        
        // Total pendapatan tahun ini
        $revenue_this_year = array_sum(array_column($monthly_revenue, 'revenue'));
        
        // Total pendapatan per hari (hari ini)
        // Cash/QRIS langsung dihitung, Transfer hanya yang terverifikasi
        $revenue_today = Order::whereDate('tanggal_order', Carbon::today())
            ->whereIn('status', ['diproses', 'selesai', 'diambil'])
            ->where(function($query) {
                $query->whereIn('payment_method', ['cash', 'qris'])
                    ->orWhere(function($q) {
                        $q->where('payment_method', 'transfer')
                          ->whereNotNull('payment_verified_at');
                    });
            })
            ->sum('total_harga');
        
        // Total pendapatan per bulan (bulan ini)
        $revenue_this_month = Order::whereYear('tanggal_order', Carbon::now()->year)
            ->whereMonth('tanggal_order', Carbon::now()->month)
            ->whereIn('status', ['diproses', 'selesai', 'diambil'])
            ->where(function($query) {
                $query->whereIn('payment_method', ['cash', 'qris'])
                    ->orWhere(function($q) {
                        $q->where('payment_method', 'transfer')
                          ->whereNotNull('payment_verified_at');
                    });
            })
            ->sum('total_harga');
        
        $data = [
            'total_users' => $total_users,
            'total_categories' => Category::count(),
            'total_menus' => $total_menus,
            'total_orders' => $total_orders,
            'pending_orders' => Order::where('status', 'pending')->count(),
            'pending_payments' => $pending_payments,
            'total_pending_amount' => $total_pending_amount,
            'total_pending_count' => $total_pending_count,
            'belum_upload_count' => $belum_upload_count,
            'belum_upload_amount' => $belum_upload_amount,
            'ditolak_count' => $ditolak_count,
            'ditolak_amount' => $ditolak_amount,
            'revenue_today' => $revenue_today,
            'revenue_this_month' => $revenue_this_month,
            'revenue_this_year' => $revenue_this_year,
            'monthly_revenue' => $monthly_revenue,
            'current_year' => $year,
            'recent_orders' => Order::with(['user', 'orderDetails.menu.category'])
                ->latest()
                ->take(10)
                ->get(),
        ];

        return view('admin.dashboard', $data);
    }
}
