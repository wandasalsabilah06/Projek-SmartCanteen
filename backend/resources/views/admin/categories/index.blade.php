@extends('layouts.app')

@section('title', 'Data Kategori')
@section('page-title', 'Data Kategori')

@section('content')
<div class="mb-3">
    <a href="{{ route('admin.categories.create') }}" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i> Tambah Kategori
    </a>
</div>

<div class="card">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th width="5%">ID</th>
                        <th width="40%">Nama Kategori</th>
                        <th width="35%">Jumlah Menu / Target</th>
                        <th width="20%">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($categories as $category)
                    <tr>
                        <td>{{ $category->id }}</td>
                        <td>{{ $category->nama_kategori }}</td>
                        <td>
                            @if($category->target_jumlah_menu > 0)
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge bg-info">{{ $category->menus_count }}</span>
                                    <span class="text-muted">/</span>
                                    <span class="badge bg-secondary">{{ $category->target_jumlah_menu }}</span>
                                    @php
                                        $percentage = round(($category->menus_count / $category->target_jumlah_menu) * 100, 1);
                                    @endphp
                                    <div class="progress flex-grow-1" style="height: 20px;">
                                        <div class="progress-bar {{ $percentage >= 100 ? 'bg-success' : ($percentage >= 50 ? 'bg-warning' : 'bg-danger') }}" 
                                             role="progressbar" 
                                             style="width: {{ min($percentage, 100) }}%;" 
                                             aria-valuenow="{{ $percentage }}" 
                                             aria-valuemin="0" 
                                             aria-valuemax="100">
                                            {{ $percentage }}%
                                        </div>
                                    </div>
                                </div>
                            @else
                                <span class="badge bg-info">{{ $category->menus_count }} Menu</span>
                                <small class="text-muted">/ Tidak ada target</small>
                            @endif
                        </td>
                        <td>
                            <a href="{{ route('admin.categories.edit', $category) }}" class="btn btn-sm btn-warning">
                                <i class="bi bi-pencil"></i> Edit
                            </a>
                            <form action="{{ route('admin.categories.destroy', $category) }}" method="POST" class="d-inline" onsubmit="return confirm('Yakin ingin menghapus?')">
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
                        <td colspan="4" class="text-center">Tidak ada data</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-3">
            {{ $categories->links() }}
        </div>
    </div>
</div>
@endsection
