@extends('layouts.app')

@section('title', 'Data Menu')
@section('page-title', 'Data Menu')

@section('content')
<div class="mb-3">
    <a href="{{ route('admin.menus.create') }}" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i> Tambah Menu
    </a>
</div>

<div class="card">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Gambar</th>
                        <th>Nama Menu</th>
                        <th>Kategori</th>
                        <th>Harga</th>
                        <th>Stok</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($menus as $menu)
                    <tr>
                        <td>{{ $menu->id }}</td>
                        <td>
                            @if($menu->gambar)
                                <img src="{{ asset($menu->gambar) }}" alt="{{ $menu->nama_menu }}" width="50" height="50" class="rounded">
                            @else
                                <span class="badge bg-secondary">No Image</span>
                            @endif
                        </td>
                        <td>{{ $menu->nama_menu }}</td>
                        <td>
                            <span class="badge bg-success">{{ $menu->category->nama_kategori }}</span>
                        </td>
                        <td>Rp {{ number_format($menu->harga, 0, ',', '.') }}</td>
                        <td>
                            <span class="badge bg-{{ $menu->stok > 10 ? 'success' : ($menu->stok > 0 ? 'warning' : 'danger') }}">
                                {{ $menu->stok }}
                            </span>
                        </td>
                        <td>
                            <a href="{{ route('admin.menus.edit', $menu) }}" class="btn btn-sm btn-warning">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <form action="{{ route('admin.menus.destroy', $menu) }}" method="POST" class="d-inline" onsubmit="return confirm('Yakin ingin menghapus?')">
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
                        <td colspan="7" class="text-center">Tidak ada data</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-3">
            {{ $menus->links() }}
        </div>
    </div>
</div>
@endsection
