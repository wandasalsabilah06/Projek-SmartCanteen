@extends('layouts.app')

@section('title', 'Tambah Item ke Order')
@section('page-title', 'Tambah Item ke Order #' . $order->id)

@section('content')
<div class="card">
    <div class="card-body">
        <form action="{{ route('admin.orders.details.store', $order) }}" method="POST">
            @csrf
            <div class="mb-3">
                <label for="menu_id" class="form-label">Menu</label>
                <select class="form-select @error('menu_id') is-invalid @enderror" id="menu_id" name="menu_id" required>
                    <option value="">Pilih Menu</option>
                    @foreach($menus as $menu)
                        <option value="{{ $menu->id }}" 
                                data-harga="{{ $menu->harga }}" 
                                data-stok="{{ $menu->stok }}"
                                {{ old('menu_id') == $menu->id ? 'selected' : '' }}>
                            {{ $menu->nama_menu }} - Rp {{ number_format($menu->harga, 0, ',', '.') }} (Stok: {{ $menu->stok }})
                        </option>
                    @endforeach
                </select>
                @error('menu_id')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="qty" class="form-label">Quantity</label>
                <input type="number" class="form-control @error('qty') is-invalid @enderror" id="qty" name="qty" value="{{ old('qty', 1) }}" min="1" required>
                @error('qty')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label class="form-label">Subtotal</label>
                <div class="alert alert-info" id="subtotal-display">
                    Rp 0
                </div>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">Tambahkan</button>
                <a href="{{ route('admin.orders.show', $order) }}" class="btn btn-secondary">Kembali</a>
            </div>
        </form>
    </div>
</div>
@endsection

@section('scripts')
<script>
    const menuSelect = document.getElementById('menu_id');
    const qtyInput = document.getElementById('qty');
    const subtotalDisplay = document.getElementById('subtotal-display');

    function updateSubtotal() {
        const selectedOption = menuSelect.options[menuSelect.selectedIndex];
        const harga = parseFloat(selectedOption.dataset.harga || 0);
        const qty = parseInt(qtyInput.value || 0);
        const subtotal = harga * qty;
        
        subtotalDisplay.textContent = 'Rp ' + subtotal.toLocaleString('id-ID');
    }

    menuSelect.addEventListener('change', updateSubtotal);
    qtyInput.addEventListener('input', updateSubtotal);
</script>
@endsection
