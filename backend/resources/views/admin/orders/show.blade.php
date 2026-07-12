@extends('layouts.app')

@section('title', 'Detail Order')
@section('page-title', 'Detail Order #' . $order->id)

@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5>Detail Pesanan</h5>
                <a href="{{ route('admin.orders.details.create', $order) }}" class="btn btn-sm btn-success">
                    <i class="bi bi-plus-circle"></i> Tambah Item
                </a>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Menu</th>
                                <th>Kategori</th>
                                <th>Harga</th>
                                <th>Qty</th>
                                <th>Subtotal</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($order->orderDetails as $detail)
                            <tr>
                                <td>{{ $detail->menu->nama_menu }}</td>
                                <td>
                                    <span class="badge bg-success">{{ $detail->menu->category->nama_kategori }}</span>
                                </td>
                                <td>Rp {{ number_format($detail->harga, 0, ',', '.') }}</td>
                                <td>{{ $detail->qty }}</td>
                                <td>Rp {{ number_format($detail->subtotal, 0, ',', '.') }}</td>
                                <td>
                                    <form action="{{ route('admin.orders.details.destroy', [$order, $detail]) }}" method="POST" class="d-inline" onsubmit="return confirm('Yakin ingin menghapus item ini?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-danger">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="6" class="text-center">Belum ada item</td>
                            </tr>
                            @endforelse
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4" class="text-end">Total:</th>
                                <th colspan="2">Rp {{ number_format($order->total_harga, 0, ',', '.') }}</th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card mb-4">
            <div class="card-header">
                <h5>Informasi Order</h5>
            </div>
            <div class="card-body">
                <table class="table table-borderless">
                    <tr>
                        <td><strong>ID Order:</strong></td>
                        <td>#{{ $order->id }}</td>
                    </tr>
                    <tr>
                        <td><strong>Tanggal:</strong></td>
                        <td>{{ $order->tanggal_order ? \Carbon\Carbon::parse($order->tanggal_order)->format('d/m/Y H:i') : '-' }}</td>
                    </tr>
                    <tr>
                        <td><strong>Nama User:</strong></td>
                        <td>{{ $order->user->name }}</td>
                    </tr>
                    <tr>
                        <td><strong>Email:</strong></td>
                        <td>{{ $order->user->email }}</td>
                    </tr>
                    <tr>
                        <td><strong>Status:</strong></td>
                        <td>
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
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h5>Update Status</h5>
            </div>
            <div class="card-body">
                <form action="{{ route('admin.orders.updateStatus', $order) }}" method="POST">
                    @csrf
                    @method('PATCH')
                    <div class="mb-3">
                        <label for="status" class="form-label">Status</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="pending" {{ $order->status == 'pending' ? 'selected' : '' }}>Pending</option>
                            <option value="diproses" {{ $order->status == 'diproses' ? 'selected' : '' }}>Diproses</option>
                            <option value="selesai" {{ $order->status == 'selesai' ? 'selected' : '' }}>Selesai</option>
                            <option value="dibatalkan" {{ $order->status == 'dibatalkan' ? 'selected' : '' }}>Dibatalkan</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Update Status</button>
                </form>
            </div>
        </div>

        <div class="mt-3">
            <a href="{{ route('admin.orders.index') }}" class="btn btn-secondary w-100">Kembali</a>
        </div>
    </div>
</div>
@endsection
