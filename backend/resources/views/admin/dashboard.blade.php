@extends('layouts.app')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')

@section('content')
<!-- Statistics Cards Row 1 -->
<div class="row">
    <div class="col-md-3">
        <div class="card text-white bg-primary mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="card-title">Pengguna</h5>
                        <h2>{{ $total_users }}</h2>
                        <small>(tanpa admin)</small>
                    </div>
                    <i class="bi bi-people fs-1"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-info mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="card-title">Menu</h5>
                        <h2>{{ $total_menus }}</h2>
                        <small>{{ $total_categories }} kategori</small>
                    </div>
                    <i class="bi bi-list-ul fs-1"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-warning mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="card-title">Orders</h5>
                        <h2>{{ $total_orders }}</h2>
                        <small>Pending: {{ $pending_orders }}</small>
                    </div>
                    <i class="bi bi-cart fs-1"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-success mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="card-title">Pendapatan Tahun Ini</h5>
                        <h2>{{ number_format($revenue_this_year / 1000, 0) }}K</h2>
                        <small>Rp {{ number_format($revenue_this_year, 0, ',', '.') }}</small>
                    </div>
                    <i class="bi bi-cash-stack fs-1"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Pembayaran Statistics Row 2 - 4 Cards -->
<div class="row">
    <div class="col-md-3">
        <div class="card border-danger mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="card-title text-muted mb-2">Menunggu Verifikasi</h6>
                        <h4 class="text-danger mb-1">{{ $total_pending_count }}</h4>
                        <small class="text-muted">Rp {{ number_format($total_pending_amount, 0, ',', '.') }}</small>
                    </div>
                    <i class="bi bi-clock-history fs-1 text-danger"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-warning mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="card-title text-muted mb-2">Belum Upload Bukti</h6>
                        <h4 class="text-warning mb-1">{{ $belum_upload_count }}</h4>
                        <small class="text-muted">Rp {{ number_format($belum_upload_amount, 0, ',', '.') }}</small>
                    </div>
                    <i class="bi bi-upload fs-1 text-warning"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-secondary mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="card-title text-muted mb-2">Pembayaran Ditolak</h6>
                        <h4 class="text-secondary mb-1">{{ $ditolak_count }}</h4>
                        <small class="text-muted">Rp {{ number_format($ditolak_amount, 0, ',', '.') }}</small>
                    </div>
                    <i class="bi bi-x-circle fs-1 text-secondary"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-success mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="card-title text-muted mb-2">Pendapatan Bulan Ini</h6>
                        <h4 class="text-success mb-1">{{ number_format($revenue_this_month / 1000, 0) }}K</h4>
                        <small class="text-muted">Rp {{ number_format($revenue_this_month, 0, ',', '.') }}</small>
                    </div>
                    <i class="bi bi-calendar-check fs-1 text-success"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Pendapatan Bulanan Section -->
<div class="row mt-2">
    <div class="col-12">
        <div class="card">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-bar-chart-fill text-primary"></i> Pendapatan Bulanan ({{ $current_year }})
                </h5>
                <span class="badge bg-primary">Total: Rp {{ number_format($revenue_this_year, 0, ',', '.') }}</span>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th width="10%">Bulan</th>
                                <th width="70%">Progress</th>
                                <th width="20%" class="text-end">Total Pendapatan</th>
                            </tr>
                        </thead>
                        <tbody>
                            @php
                                $max_revenue = max(array_column($monthly_revenue, 'revenue'));
                                $max_revenue = $max_revenue > 0 ? $max_revenue : 1;
                            @endphp
                            @foreach($monthly_revenue as $data)
                            <tr>
                                <td><strong>{{ $data['month_name'] }}</strong></td>
                                <td>
                                    <div class="progress" style="height: 25px;">
                                        @php
                                            $percentage = $max_revenue > 0 ? ($data['revenue'] / $max_revenue) * 100 : 0;
                                            $color = $data['revenue'] > 0 ? 'bg-success' : 'bg-light';
                                        @endphp
                                        <div class="progress-bar {{ $color }}" 
                                             role="progressbar" 
                                             style="width: {{ $percentage }}%"
                                             aria-valuenow="{{ $percentage }}" 
                                             aria-valuemin="0" 
                                             aria-valuemax="100">
                                        </div>
                                    </div>
                                </td>
                                <td class="text-end">
                                    <strong class="{{ $data['revenue'] > 0 ? 'text-success' : 'text-muted' }}">
                                        Rp {{ number_format($data['revenue'], 0, ',', '.') }}
                                    </strong>
                                </td>
                            </tr>
                            @endforeach
                            <tr class="table-active">
                                <td colspan="2" class="text-end"><strong>Total Tahun Ini:</strong></td>
                                <td class="text-end">
                                    <h5 class="mb-0 text-success">Rp {{ number_format($revenue_this_year, 0, ',', '.') }}</h5>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Pembayaran Pending Section - SEMUA Metode Pembayaran -->
@if($pending_payments->count() > 0)
<div class="row mt-3">
    <div class="col-12">
        <div class="card border-warning">
            <div class="card-header bg-warning text-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-exclamation-triangle"></i> Orders Pending (Semua Metode Pembayaran)
                </h5>
                <span class="badge bg-light text-dark">{{ $pending_payments->count() }} order</span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle">
                        <thead class="table-light">
                            <tr>
                                <th width="8%">Order ID</th>
                                <th width="20%">Pengguna</th>
                                <th width="15%">Tanggal Order</th>
                                <th width="15%" class="text-end">Total</th>
                                <th width="12%" class="text-center">Metode Pembayaran</th>
                                <th width="12%" class="text-center">Bukti Transfer</th>
                                <th width="8%" class="text-center">Status</th>
                                <th width="10%" class="text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($pending_payments as $payment)
                            <tr>
                                <td><strong>#{{ $payment->id }}</strong></td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <i class="bi bi-person-circle me-2 fs-4 text-primary"></i>
                                        <div>
                                            <div class="fw-bold">{{ $payment->user->name }}</div>
                                            <small class="text-muted">{{ $payment->user->email }}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <i class="bi bi-calendar3"></i> {{ \Carbon\Carbon::parse($payment->tanggal_order)->format('d M Y') }}
                                    <br>
                                    <small class="text-muted">{{ \Carbon\Carbon::parse($payment->tanggal_order)->format('H:i') }}</small>
                                </td>
                                <td class="text-end">
                                    <strong class="text-primary">Rp {{ number_format($payment->total_harga, 0, ',', '.') }}</strong>
                                </td>
                                <td class="text-center">
                                    @if($payment->payment_method == 'cash')
                                        <span class="badge bg-success">
                                            <i class="bi bi-cash"></i> Cash
                                        </span>
                                    @elseif($payment->payment_method == 'qris')
                                        <span class="badge bg-info">
                                            <i class="bi bi-qr-code"></i> QRIS
                                        </span>
                                    @elseif($payment->payment_method == 'transfer')
                                        <span class="badge bg-primary">
                                            <i class="bi bi-bank"></i> Transfer
                                        </span>
                                    @else
                                        <span class="badge bg-secondary">
                                            {{ ucfirst($payment->payment_method) }}
                                        </span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    @if($payment->payment_method == 'transfer')
                                        @if($payment->payment_proof)
                                            <span class="badge bg-info">
                                                <i class="bi bi-image"></i> Tersedia
                                            </span>
                                        @else
                                            <span class="badge bg-secondary">
                                                <i class="bi bi-upload"></i> Belum Upload
                                            </span>
                                        @endif
                                    @else
                                        <span class="text-muted">-</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <span class="badge bg-warning">
                                        <i class="bi bi-clock-history"></i> Pending
                                    </span>
                                </td>
                                <td class="text-center">
                                    <a href="{{ route('admin.orders.show', $payment) }}" class="btn btn-sm btn-primary">
                                        <i class="bi bi-eye"></i> Lihat
                                    </a>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                        <tfoot class="table-light">
                            <tr>
                                <td colspan="3" class="text-end"><strong>Total ({{ $pending_payments->count() }} order):</strong></td>
                                <td class="text-end"><strong class="text-danger fs-5">Rp {{ number_format($pending_payments->sum('total_harga'), 0, ',', '.') }}</strong></td>
                                <td colspan="4"></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@else
<div class="row mt-3">
    <div class="col-12">
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="bi bi-check-circle fs-1 text-success"></i>
                <h5 class="mt-3">Tidak Ada Order Pending</h5>
                <p class="text-muted">Semua order sudah diproses.</p>
            </div>
        </div>
    </div>
</div>
@endif

<!-- Recent Orders Section -->
<div class="row mt-4">
    <div class="col-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-clock-history"></i> Orders Terbaru
                </h5>
                <a href="{{ route('admin.orders.index') }}" class="btn btn-sm btn-primary">
                    Lihat Semua <i class="bi bi-arrow-right"></i>
                </a>
            </div>
            <div class="card-body">
                @if($recent_orders->count() > 0)
                    @foreach($recent_orders as $order)
                    <div class="card mb-3 {{ $loop->last ? '' : 'border-bottom' }}">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div>
                                            <h6 class="mb-1">
                                                <i class="bi bi-receipt"></i> Order #{{ $order->id }} 
                                                @php
                                                    $statusColors = [
                                                        'pending' => 'warning',
                                                        'diproses' => 'info',
                                                        'selesai' => 'success',
                                                        'dibatalkan' => 'danger'
                                                    ];
                                                @endphp
                                                <span class="badge bg-{{ $statusColors[$order->status] ?? 'secondary' }}">
                                                    {{ ucfirst($order->status) }}
                                                </span>
                                            </h6>
                                            <p class="mb-1 text-muted small">
                                                <i class="bi bi-person"></i> {{ $order->user->name }} 
                                                <span class="mx-2">|</span>
                                                <i class="bi bi-calendar"></i> {{ $order->tanggal_order ? \Carbon\Carbon::parse($order->tanggal_order)->format('d/m/Y H:i') : '-' }}
                                            </p>
                                        </div>
                                        <div class="text-end">
                                            <h5 class="mb-0 text-primary">Rp {{ number_format($order->total_harga, 0, ',', '.') }}</h5>
                                        </div>
                                    </div>

                                    <!-- Order Details -->
                                    @if($order->orderDetails->count() > 0)
                                    <div class="mt-3">
                                        <small class="text-muted fw-bold">Detail Pesanan:</small>
                                        <div class="table-responsive mt-2">
                                            <table class="table table-sm table-bordered mb-0">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th width="40%">Menu</th>
                                                        <th width="20%">Kategori</th>
                                                        <th width="15%" class="text-center">Qty</th>
                                                        <th width="15%" class="text-end">Harga</th>
                                                        <th width="15%" class="text-end">Subtotal</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    @foreach($order->orderDetails as $detail)
                                                    <tr>
                                                        <td>{{ $detail->menu->nama_menu }}</td>
                                                        <td>
                                                            <span class="badge bg-success">{{ $detail->menu->category->nama_kategori }}</span>
                                                        </td>
                                                        <td class="text-center">{{ $detail->qty }}</td>
                                                        <td class="text-end">Rp {{ number_format($detail->harga, 0, ',', '.') }}</td>
                                                        <td class="text-end fw-bold">Rp {{ number_format($detail->subtotal, 0, ',', '.') }}</td>
                                                    </tr>
                                                    @endforeach
                                                    <tr class="table-active">
                                                        <td colspan="4" class="text-end fw-bold">Total:</td>
                                                        <td class="text-end fw-bold text-primary">Rp {{ number_format($order->total_harga, 0, ',', '.') }}</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    @else
                                    <div class="alert alert-warning mt-2 mb-0">
                                        <small><i class="bi bi-exclamation-triangle"></i> Belum ada item dalam order ini</small>
                                    </div>
                                    @endif
                                </div>

                                <div class="col-md-4 border-start">
                                    <div class="d-flex flex-column h-100">
                                        <div class="mb-3">
                                            <small class="text-muted d-block mb-2">Informasi Order</small>
                                            <div class="mb-2">
                                                <small class="text-muted">Jumlah Item:</small>
                                                <span class="badge bg-info ms-2">{{ $order->orderDetails->sum('qty') }} item</span>
                                            </div>
                                            <div class="mb-2">
                                                <small class="text-muted">Jenis Menu:</small>
                                                <span class="badge bg-secondary ms-2">{{ $order->orderDetails->count() }} menu</span>
                                            </div>
                                        </div>
                                        
                                        <div class="mt-auto">
                                            <a href="{{ route('admin.orders.show', $order) }}" class="btn btn-sm btn-outline-primary w-100">
                                                <i class="bi bi-eye"></i> Lihat Detail
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    @endforeach
                @else
                    <div class="text-center py-5">
                        <i class="bi bi-inbox fs-1 text-muted"></i>
                        <p class="text-muted mt-2">Belum ada order</p>
                        <a href="{{ route('admin.orders.create') }}" class="btn btn-primary">
                            <i class="bi bi-plus-circle"></i> Buat Order Baru
                        </a>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection
