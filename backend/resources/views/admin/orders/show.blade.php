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
                        <td><strong>Metode Bayar:</strong></td>
                        <td>
                            @php
                                $paymentLabels = [
                                    'cash' => 'Tunai',
                                    'transfer' => 'Transfer Bank',
                                    'qris' => 'QRIS'
                                ];
                            @endphp
                            <span class="badge bg-info">
                                {{ $paymentLabels[$order->payment_method] ?? ucfirst($order->payment_method) }}
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Status:</strong></td>
                        <td>
                            @php
                                $statusColors = [
                                    'pending' => 'warning',
                                    'diproses' => 'info',
                                    'selesai' => 'success',
                                    'diambil' => 'primary',
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

        @if($order->payment_method === 'transfer')
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5>Pembayaran Transfer</h5>
                @php
                    $paymentStatus = $order->payment_status;
                    $statusBadges = [
                        'belum_upload' => ['bg' => 'secondary', 'text' => 'Belum Upload'],
                        'menunggu_verifikasi' => ['bg' => 'warning', 'text' => 'Menunggu Verifikasi'],
                        'terverifikasi' => ['bg' => 'success', 'text' => 'Terverifikasi'],
                        'ditolak' => ['bg' => 'danger', 'text' => 'Ditolak'],
                    ];
                    $badge = $statusBadges[$paymentStatus] ?? ['bg' => 'secondary', 'text' => 'Unknown'];
                @endphp
                <span class="badge bg-{{ $badge['bg'] }}">{{ $badge['text'] }}</span>
            </div>
            <div class="card-body">
                @if($order->payment_proof)
                    <div class="mb-3">
                        <label class="form-label"><strong>Bukti Transfer:</strong></label>
                        <div class="text-center">
                            <!-- Debug Info (hapus di production) -->
                            <div class="alert alert-info mb-2" style="font-size: 11px;">
                                <strong>Path:</strong> {{ $order->payment_proof }}<br>
                                <strong>URL:</strong> <a href="{{ $order->payment_proof_url }}" target="_blank">{{ $order->payment_proof_url }}</a>
                            </div>
                            
                            <a href="{{ $order->payment_proof_url }}" target="_blank" data-bs-toggle="modal" data-bs-target="#paymentProofModal">
                                <img src="{{ $order->payment_proof_url }}" 
                                     alt="Bukti Transfer" 
                                     class="img-fluid rounded" 
                                     style="max-height: 300px; cursor: pointer; border: 2px solid #dee2e6;"
                                     onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'alert alert-warning\'><i class=\'bi bi-exclamation-triangle\'></i><br>Gambar tidak dapat dimuat<br><small>Path: {{ $order->payment_proof }}</small><br><a href=\'{{ $order->payment_proof_url }}\' target=\'_blank\' class=\'btn btn-sm btn-primary mt-2\'>Coba Buka Langsung</a></div>';">
                            </a>
                            <p class="text-muted mt-2 mb-0" style="font-size: 12px;">
                                <i class="bi bi-info-circle"></i> Klik gambar untuk memperbesar
                            </p>
                            <div class="mt-2">
                                <small class="text-muted">
                                    <i class="bi bi-link-45deg"></i> 
                                    <a href="{{ $order->payment_proof_url }}" target="_blank" class="text-decoration-none">
                                        Buka di tab baru
                                    </a>
                                </small>
                            </div>
                        </div>
                    </div>

                    @if($order->payment_verified_at)
                        <div class="alert alert-success mb-3">
                            <i class="bi bi-check-circle"></i>
                            <strong>Diverifikasi</strong><br>
                            <small>
                                {{ $order->payment_verified_at->format('d M Y, H:i') }}
                                @if($order->verifiedBy)
                                    oleh {{ $order->verifiedBy->name }}
                                @endif
                            </small>
                        </div>
                    @elseif($order->payment_rejection_reason)
                        <div class="alert alert-danger mb-3">
                            <i class="bi bi-x-circle"></i>
                            <strong>Ditolak</strong><br>
                            <small>Alasan: {{ $order->payment_rejection_reason }}</small>
                        </div>
                    @endif

                    @if(!$order->payment_verified_at && !$order->payment_rejection_reason)
                        <div class="d-grid gap-2">
                            <form action="{{ route('admin.orders.verifyPayment', $order) }}" method="POST" class="d-inline">
                                @csrf
                                <button type="submit" class="btn btn-success w-100" onclick="return confirm('Terima pembayaran ini?')">
                                    <i class="bi bi-check-circle"></i> Terima Pembayaran
                                </button>
                            </form>
                            <button type="button" class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#rejectModal">
                                <i class="bi bi-x-circle"></i> Tolak Pembayaran
                            </button>
                        </div>
                    @endif
                @else
                    <div class="alert alert-secondary text-center">
                        <i class="bi bi-clock-history" style="font-size: 2rem;"></i>
                        <p class="mb-0 mt-2">Menunggu customer upload bukti transfer</p>
                    </div>
                @endif
            </div>
        </div>
        @endif

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
                            <option value="selesai" {{ $order->status == 'selesai' ? 'selected' : '' }}>Selesai (Ready)</option>
                            <option value="diambil" {{ $order->status == 'diambil' ? 'selected' : '' }}>Diambil (Collected)</option>
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

<!-- Modal Tolak Pembayaran -->
<div class="modal fade" id="rejectModal" tabindex="-1" aria-labelledby="rejectModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="{{ route('admin.orders.rejectPayment', $order) }}" method="POST">
                @csrf
                <div class="modal-header">
                    <h5 class="modal-title" id="rejectModalLabel">Tolak Pembayaran</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="rejection_reason" class="form-label">Alasan Penolakan <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="rejection_reason" name="rejection_reason" rows="4" required placeholder="Contoh: Bukti transfer tidak jelas, jumlah tidak sesuai, dll."></textarea>
                    </div>
                    <div class="alert alert-warning">
                        <i class="bi bi-exclamation-triangle"></i> 
                        Customer akan diminta untuk upload ulang bukti transfer.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-danger">Tolak Pembayaran</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Preview Bukti Transfer -->
@if($order->payment_proof)
<div class="modal fade" id="paymentProofModal" tabindex="-1" aria-labelledby="paymentProofModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="paymentProofModalLabel">Bukti Transfer - Order #{{ $order->id }}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center">
                <img src="{{ $order->payment_proof_url }}" alt="Bukti Transfer" class="img-fluid" style="max-height: 80vh;">
            </div>
            <div class="modal-footer">
                <a href="{{ $order->payment_proof_url }}" target="_blank" class="btn btn-primary">
                    <i class="bi bi-download"></i> Download
                </a>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
            </div>
        </div>
    </div>
</div>
@endif
@endsection
