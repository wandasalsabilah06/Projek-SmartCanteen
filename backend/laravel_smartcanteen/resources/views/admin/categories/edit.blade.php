@extends('layouts.app')

@section('title', 'Edit Kategori')
@section('page-title', 'Edit Kategori')

@section('content')
<div class="card">
    <div class="card-body">
        <form action="{{ route('admin.categories.update', $category) }}" method="POST">
            @csrf
            @method('PUT')
            <div class="mb-3">
                <label for="nama_kategori" class="form-label">Nama Kategori</label>
                <input type="text" class="form-control @error('nama_kategori') is-invalid @enderror" id="nama_kategori" name="nama_kategori" value="{{ old('nama_kategori', $category->nama_kategori) }}" required>
                @error('nama_kategori')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="target_jumlah_menu" class="form-label">Target Jumlah Menu</label>
                <input type="number" class="form-control @error('target_jumlah_menu') is-invalid @enderror" id="target_jumlah_menu" name="target_jumlah_menu" value="{{ old('target_jumlah_menu', $category->target_jumlah_menu) }}" min="0">
                <small class="text-muted">Target/rencana jumlah menu untuk kategori ini (opsional)</small>
                @error('target_jumlah_menu')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="alert alert-info">
                <strong>Jumlah Menu Saat Ini:</strong> {{ $category->menus()->count() }} menu
                @if($category->target_jumlah_menu > 0)
                <br>
                <strong>Target:</strong> {{ $category->target_jumlah_menu }} menu
                <br>
                @php
                    $current = $category->menus()->count();
                    $target = $category->target_jumlah_menu;
                    $percentage = $target > 0 ? round(($current / $target) * 100, 1) : 0;
                @endphp
                <div class="progress mt-2" style="height: 25px;">
                    <div class="progress-bar {{ $percentage >= 100 ? 'bg-success' : ($percentage >= 50 ? 'bg-warning' : 'bg-danger') }}" 
                         role="progressbar" 
                         style="width: {{ min($percentage, 100) }}%;" 
                         aria-valuenow="{{ $percentage }}" 
                         aria-valuemin="0" 
                         aria-valuemax="100">
                        {{ $percentage }}%
                    </div>
                </div>
                @endif
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">Update</button>
                <a href="{{ route('admin.categories.index') }}" class="btn btn-secondary">Kembali</a>
            </div>
        </form>
    </div>
</div>
@endsection
