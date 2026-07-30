# Fitur Registrasi Pengguna Baru

## Perubahan yang Dilakukan

### Backend (Laravel)

1. **AuthController.php** - Menambahkan method `register()`
   - Validasi: name, email (unique), password (min 6 karakter), password_confirmation
   - Otomatis membuat user baru dengan role 'pelanggan'
   - Return user data setelah registrasi berhasil

2. **routes/api.php** - Menambahkan route baru
   ```php
   Route::post('/register', [AuthController::class, 'register']);
   ```

### Frontend (Flutter)

1. **app_routes.dart** - Menambahkan route registrasi
   ```dart
   static const String register = '/register';
   ```

2. **app_router.dart** - Mendaftarkan route register
   - Route `/register` menuju `RegisterScreen`
   - Route register adalah publik (tidak perlu autentikasi)

3. **auth_provider.dart** - Menambahkan method `register()`
   - Validasi dan error handling lengkap
   - Otomatis login setelah registrasi berhasil
   - Simpan data user ke SharedPreferences

4. **register_screen.dart** - Screen registrasi baru (BARU)
   - Form: Nama Lengkap, Email, Password, Konfirmasi Password
   - Validasi client-side untuk semua field
   - Design konsisten dengan login screen
   - Link kembali ke login untuk user yang sudah punya akun

5. **login_screen.dart** - Update dengan link ke registrasi
   - Tambahan link "Belum punya akun? Daftar di sini"
   - Preserves query param 'from' untuk redirect setelah registrasi

## Cara Menggunakan

### Dari Sisi Pengguna

1. Pengguna yang ingin memesan tetapi belum punya akun akan diarahkan ke login
2. Di halaman login, klik **"Belum punya akun? Daftar di sini"**
3. Isi form registrasi:
   - Nama lengkap (minimal 3 karakter)
   - Email yang valid dan belum terdaftar
   - Password (minimal 6 karakter)
   - Konfirmasi password (harus sama dengan password)
4. Klik **"Daftar Sekarang"**
5. Jika berhasil, otomatis login dan diarahkan ke halaman tujuan (cart/checkout)

### Validasi

**Frontend:**
- Nama: tidak boleh kosong, minimal 3 karakter
- Email: tidak boleh kosong, harus format valid (@, .)
- Password: tidak boleh kosong, minimal 6 karakter
- Konfirmasi password: harus sama dengan password

**Backend:**
- Name: required, string, max 255 karakter
- Email: required, valid email, unique (tidak boleh duplikat)
- Password: required, string, minimal 6 karakter, confirmed

## Testing

### Test Manual

1. **Registrasi Berhasil:**
   ```
   Nama: John Doe
   Email: john@example.com
   Password: password123
   Konfirmasi: password123
   ```
   ✓ User terdaftar dan langsung login

2. **Email Sudah Terdaftar:**
   ```
   Email: admin@admin.com (sudah ada)
   ```
   ✗ Error: "The email has already been taken"

3. **Password Tidak Match:**
   ```
   Password: password123
   Konfirmasi: password456
   ```
   ✗ Error: "Password tidak sama" (validasi frontend)

4. **Email Tidak Valid:**
   ```
   Email: bukanemailvald
   ```
   ✗ Error: "Email tidak valid" (validasi frontend)

### Test API Langsung (Postman/Thunder Client)

**Endpoint:** `POST http://192.168.x.x:8000/api/register`

**Body (JSON):**
```json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response (201 Created):**
```json
{
  "message": "Registrasi berhasil",
  "user": {
    "id": 3,
    "name": "Test User",
    "email": "test@example.com",
    "role": "pelanggan"
  }
}
```

## Keamanan

- Password di-hash menggunakan `Hash::make()` sebelum disimpan
- Email harus unique (tidak boleh duplikat)
- User baru otomatis mendapat role 'pelanggan' (bukan admin)
- Password tidak pernah di-return dalam response API
- Validasi server-side dan client-side untuk keamanan berlapis

## Flow Lengkap Guest User

1. Guest membuka aplikasi → lihat menu (tidak perlu login)
2. Guest menambah item ke cart → perlu login
3. Redirect ke `/login?from=/cart`
4. User klik "Belum punya akun? Daftar di sini"
5. Redirect ke `/register?from=/cart`
6. User isi form registrasi dan submit
7. Jika berhasil, otomatis login dan redirect ke `/cart`
8. User bisa lanjut checkout

## Troubleshooting

### Error: "The email has already been taken"
**Penyebab:** Email sudah terdaftar di database
**Solusi:** Gunakan email lain atau login dengan email yang sudah ada

### Error: "Tidak dapat terhubung ke server"
**Penyebab:** Backend tidak berjalan atau IP salah
**Solusi:** 
1. Pastikan backend running: `php artisan serve --host=0.0.0.0 --port=8000`
2. Cek IP di `app_constants.dart` sesuai dengan IP komputer

### Error: "Koneksi timeout"
**Penyebab:** HP dan komputer tidak satu jaringan WiFi
**Solusi:** Sambungkan ke WiFi yang sama

## File yang Dimodifikasi

**Backend:**
- `app/Http/Controllers/Api/AuthController.php` (tambah method register)
- `routes/api.php` (tambah route /register)

**Frontend:**
- `lib/core/router/app_routes.dart` (tambah const register)
- `lib/core/router/app_router.dart` (tambah GoRoute register)
- `lib/features/auth/providers/auth_provider.dart` (tambah method register)
- `lib/features/auth/screens/login_screen.dart` (tambah link daftar)
- `lib/features/auth/screens/register_screen.dart` (FILE BARU)
