# Setup Storage untuk Bukti Transfer

## 🚀 Quick Fix (Windows)

Jalankan file batch yang sudah disediakan:

```bash
cd backend
fix-storage.bat
```

## 🚀 Quick Fix (Linux/Mac)

Jalankan script shell yang sudah disediakan:

```bash
cd backend
chmod +x fix-storage.sh
./fix-storage.sh
```

## ✅ Manual Setup

### 1. Buat Symbolic Link

```bash
php artisan storage:link
```

**Output yang benar:**
```
The [public/storage] link has been connected to [storage/app/public].
The links have been created.
```

### 2. Buat Folder Payment Proofs

```bash
# Windows
mkdir storage\app\public\payment_proofs

# Linux/Mac
mkdir -p storage/app/public/payment_proofs
```

### 3. Set Permission (Linux/Mac only)

```bash
chmod -R 775 storage/
chmod -R 775 public/storage/
```

### 4. Verifikasi Setup

1. **Cek symbolic link:**
   ```bash
   # Windows
   dir public\storage
   
   # Linux/Mac
   ls -la public/storage
   ```
   
   Harus ada link/shortcut ke `storage/app/public`

2. **Cek folder payment_proofs:**
   ```bash
   # Windows
   dir storage\app\public\payment_proofs
   
   # Linux/Mac
   ls -la storage/app/public/payment_proofs
   ```

3. **Test URL:**
   - Buka browser: `http://localhost:8000/storage/payment_proofs/`
   - Jika berhasil, akan muncul halaman kosong (bukan 404)

## 📁 Struktur Folder yang Benar

```
backend/
├── public/
│   └── storage/  ← SYMLINK ke storage/app/public
│       └── payment_proofs/
│           ├── image1.jpg
│           └── image2.png
│
└── storage/
    └── app/
        └── public/  ← FOLDER ASLI
            └── payment_proofs/
                ├── image1.jpg
                └── image2.png
```

## 🔍 Troubleshooting

### Gambar Tidak Muncul di Admin Panel

1. **Cek debug info di admin panel:**
   - Path: `payment_proofs/filename.jpg` ✅
   - URL: `http://localhost:8000/storage/payment_proofs/filename.jpg` ✅

2. **Test URL langsung:**
   - Copy URL dari debug info
   - Paste di browser baru
   - Jika 404 → symbolic link belum dibuat
   - Jika 403 → permission error
   - Jika OK → gambar muncul ✅

3. **Cek file ada di storage:**
   ```bash
   ls storage/app/public/payment_proofs/
   ```
   File harus ada di sini!

4. **Re-run storage:link:**
   ```bash
   # Hapus link lama
   rm public/storage        # Linux/Mac
   rmdir public\storage     # Windows
   
   # Buat ulang
   php artisan storage:link
   ```

### Error "The link already exists"

```bash
# Windows
rmdir public\storage
php artisan storage:link

# Linux/Mac
rm public/storage
php artisan storage:link
```

### Permission Denied (Linux/Mac)

```bash
sudo chown -R $USER:www-data storage/
sudo chmod -R 775 storage/
sudo chown -R $USER:www-data public/storage/
sudo chmod -R 775 public/storage/
```

### Windows - Symlink Gagal

**Solusi 1:** Jalankan CMD sebagai Administrator

**Solusi 2:** Gunakan junction link
```bash
mklink /J public\storage ..\storage\app\public
```

## 🧪 Test Upload

1. Upload bukti transfer dari Flutter app
2. Refresh halaman admin panel
3. Klik tab "Detail Order"
4. Lihat section "Pembayaran Transfer"
5. Debug info akan menampilkan:
   - Path file di database
   - URL lengkap untuk akses gambar
6. Gambar harus muncul dengan benar
7. Klik gambar untuk modal preview

## ⚙️ Konfigurasi Storage (Optional)

Edit `config/filesystems.php` jika perlu:

```php
'public' => [
    'driver' => 'local',
    'root' => storage_path('app/public'),
    'url' => env('APP_URL').'/storage',
    'visibility' => 'public',
],
```

## 📝 Notes

- Symbolic link hanya perlu dibuat **SEKALI** per server
- Jika pindah server, jalankan ulang `php artisan storage:link`
- File disimpan di `storage/app/public/payment_proofs/`
- URL akses: `public/storage/payment_proofs/`
- Model Order menggunakan `Storage::disk('public')->url()` untuk generate URL

## ✨ Fitur Admin Panel

- ✅ Preview gambar bukti transfer
- ✅ Modal untuk memperbesar gambar
- ✅ Download gambar
- ✅ Debug info (path & URL)
- ✅ Fallback jika gambar gagal dimuat
- ✅ Tombol approve/reject pembayaran
