@extends('layouts.app')

@section('title', 'Edit User')
@section('page-title', 'Edit User')

@section('content')
<div class="card">
    <div class="card-body">
        <form action="{{ route('admin.users.update', $user) }}" method="POST">
            @csrf
            @method('PUT')

            <div class="mb-3">
                <label for="name" class="form-label">Nama</label>
                <input type="text" class="form-control @error('name') is-invalid @enderror"
                    id="name" name="name" value="{{ old('name', $user->name) }}" required>
                @error('name')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input type="email" class="form-control @error('email') is-invalid @enderror"
                    id="email" name="email" value="{{ old('email', $user->email) }}" required>
                @error('email')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">
                    Password
                    <small class="text-muted">(Kosongkan jika tidak ingin mengubah)</small>
                </label>
                <div class="input-group">
                    <input type="password"
                        class="form-control @error('password') is-invalid @enderror"
                        id="password" name="password"
                        placeholder="Masukkan password baru...">
                    <button class="btn btn-outline-secondary" type="button"
                        onclick="togglePasswordVisibility('password', 'eyeIconEdit')"
                        title="Tampilkan/Sembunyikan Password">
                        <i id="eyeIconEdit" class="bi bi-eye"></i>
                    </button>
                    @error('password')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>
                <div class="form-text text-muted">Minimal 6 karakter. Kosongkan jika tidak ingin mengubah password.</div>
            </div>

            <div class="mb-3">
                <label for="role" class="form-label">Role</label>
                <select class="form-select @error('role') is-invalid @enderror"
                    id="role" name="role" required>
                    <option value="">Pilih Role</option>
                    <option value="admin"      {{ old('role', $user->role) == 'admin'      ? 'selected' : '' }}>Admin</option>
                    <option value="pelanggan"  {{ old('role', $user->role) == 'pelanggan'  ? 'selected' : '' }}>Pelanggan</option>
                </select>
                @error('role')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg"></i> Update
                </button>
                <a href="{{ route('admin.users.index') }}" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Kembali
                </a>
            </div>
        </form>
    </div>
</div>

<script>
function togglePasswordVisibility(inputId, iconId) {
    const input = document.getElementById(inputId);
    const icon  = document.getElementById(iconId);
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.replace('bi-eye', 'bi-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.replace('bi-eye-slash', 'bi-eye');
    }
}
</script>
@endsection
