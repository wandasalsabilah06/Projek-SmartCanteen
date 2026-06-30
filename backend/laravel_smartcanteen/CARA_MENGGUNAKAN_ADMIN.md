# 📖 Cara Menggunakan Admin Panel

## 🚀 Langkah-langkah Setup

### 1. Setup Database
```bash
# Jalankan migration
php artisan migrate

# Jalankan seeder untuk data awal
php artisan db:seed --class=AdminSeeder
```

### 2. Jalankan Server
```bash
php artisan serve
```

Buka browser: `http://localhost:8000`

---

## 📌 Akses Admin Panel

### URL Utama
```
http://localhost:8000/admin/dashboard
```

### Login Credentials (dari seeder)
**Admin:**
- Email: `admin@admin.com`
- Password: `password`

**User Biasa:**
- Email: `user@test.com`
- Password: `password`
- Role: `pelanggan`

---

## 🎯 Fitur-Fitur Admin

### 1. 📊 Dashboard
**URL:** `/admin/dashboard`
- Melihat total users, kategori, menu, dan orders
- Statistik order pending

### 2. 👥 User Management
**URL:** `/admin/users`

**Fitur:**
- ✅ Lihat semua users
- ✅ Tambah user baru (klik tombol "Tambah User")
- ✅ Edit user (klik icon pensil)
- ✅ Hapus user (klik icon sampah)
- ✅ Set role: admin / pelanggan

**Form Input:**
- Nama
- Email
- Password
- Role (admin/pelanggan)

### 3. 🏷️ Category Management
**URL:** `/admin/categories`

**Fitur:**
- ✅ Lihat semua kategori dengan jumlah menu
- ✅ Tambah kategori (klik "Tambah Kategori")
- ✅ Edit kategori
- ✅ Hapus kategori (tidak bisa dihapus jika masih ada menu)

**Form Input:**
- Nama Kategori

### 4. 🍔 Menu Management
**URL:** `/admin/menus`

**Fitur:**
- ✅ Lihat semua menu dengan gambar
- ✅ Tambah menu baru
- ✅ Edit menu
- ✅ Hapus menu
- ✅ Upload gambar menu
- ✅ Indikator stok (hijau > 10, kuning 1-10, merah = 0)

**Form Input:**
- Kategori (dropdown)
- Nama Menu
- Harga (angka)
- Stok (angka)
- Gambar (upload file jpg/png/gif, max 2MB)
- Deskripsi (opsional)

**Lokasi Upload:**
Gambar disimpan di: `public/uploads/menus/`

### 5. 🛒 Order Management
**URL:** `/admin/orders`

**Fitur:**
- ✅ Lihat semua orders
- ✅ Buat order baru
- ✅ Lihat detail order
- ✅ Update status order
- ✅ Hapus order
- ✅ Tambah item ke order
- ✅ Hapus item dari order
- ✅ Otomatis update total harga
- ✅ Otomatis kelola stok

**Cara Membuat Order Baru:**
1. Klik "Buat Order Baru"
2. Pilih user
3. Pilih status awal
4. Klik "Buat Order"
5. Setelah order dibuat, tambahkan item menu:
   - Klik "Tambah Item"
   - Pilih menu
   - Masukkan quantity
   - Klik "Tambahkan"
6. Total harga akan dihitung otomatis
7. Stok menu akan berkurang otomatis

**Status Order:**
- 🟡 **Pending** - Menunggu diproses
- 🔵 **Diproses** - Sedang diproses
- 🟢 **Selesai** - Sudah selesai
- 🔴 **Dibatalkan** - Dibatalkan

**Update Status:**
1. Buka detail order
2. Di sidebar kanan, pilih status baru
3. Klik "Update Status"

---

## 📁 Struktur Menu

```
Admin Panel
├── Dashboard (Statistik)
├── Users (Kelola pengguna)
├── Kategori (Kelola kategori menu)
├── Menu (Kelola menu makanan/minuman)
└── Orders (Kelola pesanan)
```

---

## 🎨 Navigasi

**Sidebar Kiri:**
- Dashboard
- Users
- Kategori
- Menu
- Orders

**Setiap Halaman:**
- 🔵 Tombol aksi di kanan atas
- 📊 Tabel data dengan pagination
- 🔍 Icon aksi: 👁️ Lihat, ✏️ Edit, 🗑️ Hapus

---

## ⚡ Fitur Otomatis

### Stok Management
- ✅ Stok berkurang otomatis saat item ditambahkan ke order
- ✅ Stok kembali saat item dihapus dari order
- ✅ Validasi stok sebelum menambah item

### Total Harga
- ✅ Dihitung otomatis berdasarkan item
- ✅ Update otomatis saat item ditambah/hapus
- ✅ Subtotal = harga × quantity

### Validasi
- ✅ Form validation untuk semua input
- ✅ Email unik untuk user
- ✅ Kategori tidak bisa dihapus jika masih ada menu
- ✅ Cek stok sebelum order

---

## 🎯 Tips Penggunaan

1. **Urutan Pengisian Data:**
   - Buat kategori dulu
   - Buat menu (pilih kategori)
   - Buat user (jika belum ada)
   - Buat order dan tambah item

2. **Upload Gambar:**
   - Format: JPG, PNG, GIF
   - Ukuran maksimal: 2MB
   - Gambar disimpan otomatis

3. **Hapus Data:**
   - Konfirmasi sebelum hapus
   - Kategori dengan menu tidak bisa dihapus
   - Hapus order akan mengembalikan stok

4. **Pagination:**
   - Setiap halaman menampilkan 10 data
   - Navigasi di bawah tabel

---

## 🔧 Troubleshooting

### Error Upload Gambar
```bash
# Pastikan folder ada dan writable
mkdir public/uploads/menus
chmod 755 public/uploads/menus
```

### Error Database
```bash
# Reset database dan seed ulang
php artisan migrate:fresh
php artisan db:seed --class=AdminSeeder
```

### Error Route
```bash
# Clear cache
php artisan route:clear
php artisan cache:clear
php artisan config:clear
```

---

## 📞 Data Sample (dari Seeder)

### Users
- Admin: admin@admin.com
- User: user@test.com

### Kategori
- Makanan
- Minuman
- Snack
- Dessert

### Menu
- Nasi Goreng (Rp 15.000)
- Mie Ayam (Rp 12.000)
- Es Teh Manis (Rp 5.000)
- Jus Jeruk (Rp 8.000)

---

Selamat menggunakan Admin Panel! 🎉
