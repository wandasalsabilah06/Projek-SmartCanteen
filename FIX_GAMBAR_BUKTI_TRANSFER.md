# 🔧 FIX: Gambar Bukti Transfer Tidak Muncul

## 🎯 Masalah

Gambar bukti transfer yang diupload dari Flutter app tidak muncul di backend admin panel Laravel. Muncul pesan "Gambar tidak dapat dimuat".

## 🔍 Penyebab

1. **Symbolic link belum dibuat** - Laravel perlu symbolic link dari `public/storage` ke `storage/app/public`
2. **Permission folder salah** - Folder storage tidak bisa diakses oleh web server
3. **URL accessor salah** - Model menggunakan URL yang tidak sesuai dengan konfigurasi

## ✅ Solusi

### Langkah 1: Jalankan Quick Fix Script

**Windows:**
```bash
cd backend
fix-storage.bat
```

**Linux/Mac:**
```bash
cd backend
chmod +x fix-storage.sh
./fix-storage.sh
```

### Langkah 2: Test Storage

Jalankan command test yang sudah dibuat:

```bash
cd backend
php artisan storage:test
```

Output yang benar:
```
✓ public/storage exists
✓ storage/app/public/payment_proofs exists
✓ Public disk accessible
✓ Created test file
✓ URL: http://localhost:8000/storage/payment_proofs/test-xxx.txt
✓ Deleted test file
```

### Langkah 3: Test Upload dari Flutter

1. Buka Flutter app
2. Checkout dengan metode **Transfer Bank**
3. Upload bukti transfer
4. Tunggu notifikasi "✓ Bukti transfer berhasil diupload"
5. Halaman berubah ke "Menunggu Verifikasi" (ORANGE)

### Langkah 4: Verifikasi di Admin Panel

1. Login ke admin panel: `http://localhost:8000/admin`
2. Menu **Orders** → pilih order yang baru
3. Di panel kanan ada card **"Pembayaran Transfer"**
4. Badge kuning: **"Menunggu Verifikasi"**
5. **Debug Info** menampilkan:
   - Path: `payment_proofs/xxxxx.jpg`
   - URL: `http://localhost:8000/storage/payment_proofs/xxxxx.jpg`
6. **Gambar harus muncul** dengan border abu-abu
7. Klik gambar → modal preview muncul
8. Klik "Buka di tab baru" → gambar terbuka di tab baru

## 🐛 Troubleshooting

### Problem: Symbolic link belum dibuat

**Gejala:**
- 404 Not Found saat akses `http://localhost:8000/storage/`
- Folder `public/storage` tidak ada

**Solusi:**
```bash
cd backend
php artisan storage:link
```

### Problem: Error "The link already exists"

**Solusi:**
```bash
# Windows
cd backend
rmdir public\storage
php artisan storage:link

# Linux/Mac
cd backend
rm public/storage
php artisan storage:link
```

### Problem: Gambar tetap tidak muncul

**Cek 1: File ada di storage?**
```bash
# Windows
dir backend\storage\app\public\payment_proofs

# Linux/Mac
ls backend/storage/app/public/payment_proofs
```

File harus ada di sini! Jika tidak ada, masalah di upload.

**Cek 2: URL bisa diakses?**
- Copy URL dari debug info
- Paste di browser baru
- Jika 404 → symbolic link belum dibuat
- Jika 403 → permission error (Linux/Mac)
- Jika gambar muncul → ✅ Setup benar, masalah di frontend

**Cek 3: Permission folder (Linux/Mac)**
```bash
cd backend
chmod -R 775 storage/
chmod -R 775 public/storage/
```

### Problem: Permission denied (Linux/Mac)

```bash
cd backend
sudo chown -R $USER:www-data storage/
sudo chmod -R 775 storage/
```

### Problem: Windows symlink gagal

**Solusi 1:** Jalankan CMD sebagai Administrator
```bash
cd backend
php artisan storage:link
```

**Solusi 2:** Gunakan Junction Link
```bash
cd backend
mklink /J public\storage ..\storage\app\public
```

## 📝 Perubahan yang Dibuat

### 1. Model Order (`backend/app/Models/Order.php`)

**Sebelum:**
```php
public function getPaymentProofUrlAttribute()
{
    if ($this->payment_proof) {
        return url('storage/' . $this->payment_proof);
    }
    return null;
}
```

**Sesudah:**
```php
public function getPaymentProofUrlAttribute()
{
    if ($this->payment_proof) {
        // Gunakan Storage::url() untuk mendapatkan URL yang benar
        return \Storage::disk('public')->url($this->payment_proof);
    }
    return null;
}
```

### 2. View Admin (`backend/resources/views/admin/orders/show.blade.php`)

Menambahkan:
- ✅ Debug info (path & URL)
- ✅ Error handler jika gambar gagal dimuat
- ✅ Tombol "Buka di tab baru"
- ✅ Fallback message

### 3. Script Helper

- ✅ `fix-storage.bat` (Windows)
- ✅ `fix-storage.sh` (Linux/Mac)
- ✅ `php artisan storage:test` (Test command)

## 🎉 Hasil Akhir

Setelah fix berhasil:

1. ✅ Upload dari Flutter berhasil
2. ✅ File tersimpan di `storage/app/public/payment_proofs/`
3. ✅ URL aksesibel: `http://localhost:8000/storage/payment_proofs/xxx.jpg`
4. ✅ Gambar muncul di admin panel
5. ✅ Modal preview berfungsi
6. ✅ Admin bisa approve/reject pembayaran
7. ✅ Status update real-time di Flutter (auto-refresh 10 detik)

## 🔄 Flow Lengkap Setelah Fix

```
FLUTTER APP:
1. Checkout → Pilih "Transfer Bank"
2. Order Tracking → Card BIRU "Upload Bukti Transfer"
3. Upload gambar → Loading "Mengupload..."
4. ✓ Sukses → Card berubah ORANGE "Menunggu Verifikasi"
   └─ Auto-refresh setiap 10 detik

ADMIN PANEL:
5. Orders → Detail Order
6. Lihat card "Pembayaran Transfer"
7. Badge KUNING "Menunggu Verifikasi"
8. Gambar bukti transfer MUNCUL ✅
9. Klik "Terima Pembayaran"

FLUTTER APP (setelah admin approve):
10. Auto-refresh mendeteksi perubahan
11. Card berubah HIJAU "Pembayaran Disetujui"
12. Lanjut ke Order Journey (Pending → Diproses → Selesai → Diambil)
```

## 📞 Support

Jika masih ada masalah:
1. Jalankan: `php artisan storage:test`
2. Screenshot output
3. Cek browser console (F12) untuk error
4. Cek Laravel log: `storage/logs/laravel.log`
