@extends('layouts.app')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')

@section('content')
<div class="row">
    <div class="col-md-3">
        <div class="card text-white bg-primary mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="card-title">Users</h5>
                        <h2>{{ $total_users }}</h2>
                    </div>
                    <i class="bi bi-people fs-1"></i>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card text-white bg-success mb-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="card-title">Kategori</h5>
                        <h2>{{ $total_categories }}</h2>
                    </div>
                    <i class="bi bi-tags fs-1"></i>
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
</div>

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
