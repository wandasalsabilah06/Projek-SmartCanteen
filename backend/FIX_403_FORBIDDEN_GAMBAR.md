# 🔧 FIX: 403 Forbidden pada Gambar Bukti Transfer

## 🎯 Masalah

Gambar bukti transfer tidak dapat ditampilkan di admin dashboard dengan error:
```
403 Forbidden
```

## 🔍 Penyebab

1. **Symbolic link tidak bekerja** dengan `php artisan serve` di Windows
2. **Storage folder** tidak accessible via HTTP
3. **CORS headers** tidak diterapkan untuk static files

## ✅ Solusi yang Diimplementasikan

### 1. **Route Khusus untuk Serve Gambar**

File: `routes/web.php`

```php
// Serve payment proof images dengan CORS
Route::get('/storage/payment_proofs/{filename}', function ($filename) {
    $path = storage_path('app/public/payment_proofs/' . $filename);
    
    if (!file_exists($path)) {
        abort(404, 'File not found');
    }
    
    $file = file_get_contents($path);
    $type = mime_content_type($path);
    
    return response($file, 200)
        ->header('Content-Type', $type)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ->header('Cache-Control', 'public, max-age=3600');
})->where('filename', '.*');
```

**Keuntungan:**
- ✅ Tidak bergantung pada symbolic link
- ✅ CORS headers otomatis ditambahkan
- ✅ Bekerja dengan `php artisan serve`
- ✅ Cache control untuk performa

### 2. **Update Model Order**

File: `app/Models/Order.php`

```php
public function getPaymentProofUrlAttribute()
{
    if ($this->payment_proof) {
        // Gunakan URL route untuk serve file (lebih reliable di php artisan serve)
        $filename = basename($this->payment_proof);
        return url("storage/payment_proofs/{$filename}");
    }
    return null;
}
```

**Perubahan:**
- Sebelum: `\Storage::disk('public')->url($this->payment_proof)`
- Sesudah: `url("storage/payment_proofs/{$filename}")`

### 3. **Added `$appends` di Model**

```php
protected $appends = [
    'payment_proof_url',
    'payment_status',
];
```

Memastikan accessor ter-serialize ke JSON response.

---

## 🚀 Cara Menggunakan

### Langkah 1: Run Fix Script (Opsional)

```bash
cd backend
fix-storage-403.bat
```

Script ini akan:
1. Hapus symbolic link lama
2. Buat symbolic link baru
3. Buat folder payment_proofs jika belum ada
4. Test storage access

### Langkah 2: Restart Server

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

### Langkah 3: Test Access

**Via Browser:**
```
http://localhost:8000/storage/payment_proofs/[filename].jpg
```

**Via Admin Dashboard:**
1. Login: `http://localhost:8000/admin`
2. Menu Orders → Detail Order
3. Lihat card "Pembayaran Transfer"
4. Gambar harus muncul ✅

---

## 🧪 Testing

### Test 1: Upload dari Flutter

1. Buka Flutter app
2. Checkout dengan Transfer Bank
3. Upload bukti transfer
4. ✓ Notifikasi "Bukti transfer berhasil diupload"

### Test 2: Lihat di Admin

1. Login admin dashboard
2. Orders → Detail order yang baru
3. Card "Pembayaran Transfer" muncul
4. **Gambar harus terlihat** (tidak 403) ✅
5. Klik gambar → Modal preview muncul
6. Klik "Buka di tab baru" → Gambar terbuka

### Test 3: Verify URL

Cek console log atau debug info di admin:
```
Path: payment_proofs/1234567890_image.jpg
URL: http://localhost:8000/storage/payment_proofs/1234567890_image.jpg
```

URL harus:
- ✅ Menggunakan route `/storage/payment_proofs/{filename}`
- ✅ Mengembalikan HTTP 200
- ✅ Content-Type: image/jpeg atau image/png
- ✅ CORS headers ada

---

## 📊 Before vs After

### Before (403 Forbidden)

```
URL: http://localhost:8000/storage/payment_proofs/xxx.jpg
→ 403 Forbidden (Symbolic link tidak bekerja)
```

### After (200 OK)

```
URL: http://localhost:8000/storage/payment_proofs/xxx.jpg
→ 200 OK (Route langsung serve file)
→ Headers:
   - Content-Type: image/jpeg
   - Access-Control-Allow-Origin: *
   - Cache-Control: public, max-age=3600
```

---

## 🐛 Troubleshooting

### Problem 1: Gambar Masih 404

**Cek:**
1. Apakah file ada di `storage/app/public/payment_proofs/`?
   ```bash
   dir backend\storage\app\public\payment_proofs
   ```

2. Apakah filename di database benar?
   ```sql
   SELECT id, payment_proof FROM orders WHERE payment_method='transfer';
   ```

**Solusi:**
- Pastikan upload berhasil dari Flutter
- Cek Laravel log: `storage/logs/laravel.log`

### Problem 2: Gambar Masih 403

**Cek:**
1. Apakah route sudah ditambahkan?
   ```bash
   php artisan route:list | findstr storage
   ```
   
   Output harus ada:
   ```
   GET|HEAD  storage/payment_proofs/{filename} ...
   ```

2. Apakah Model Order sudah update?
   ```php
   dd($order->payment_proof_url);
   ```
   
   Harus return: `http://localhost:8000/storage/payment_proofs/xxx.jpg`

**Solusi:**
- Restart Laravel server
- Clear cache: `php artisan cache:clear`

### Problem 3: CORS Error dari Flutter

**Gejala:**
```
Access to image at 'http://...' from origin 'http://...' 
has been blocked by CORS policy
```

**Solusi:**
Route sudah menambahkan CORS headers:
```php
->header('Access-Control-Allow-Origin', '*')
->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
```

Jika masih error, cek middleware CORS di `app/Http/Kernel.php`.

---

## ✅ Verification Checklist

- [x] Route `/storage/payment_proofs/{filename}` ditambahkan
- [x] Model `Order::getPaymentProofUrlAttribute()` updated
- [x] `$appends` ditambahkan di Model Order
- [x] CORS headers diterapkan
- [x] Test upload dari Flutter berhasil
- [x] Gambar muncul di admin dashboard (tidak 403)
- [x] Modal preview berfungsi
- [x] Download/buka di tab baru berfungsi

---

## 📝 Files Modified

1. ✅ `routes/web.php` - Added route untuk serve gambar
2. ✅ `app/Models/Order.php` - Updated accessor + added $appends
3. ✅ `fix-storage-403.bat` - Script helper untuk fix storage

---

## 🎉 Hasil Akhir

**Admin Dashboard sekarang:**
- ✅ Gambar bukti transfer muncul dengan benar
- ✅ Tidak ada error 403 Forbidden
- ✅ Modal preview berfungsi
- ✅ Debug info menampilkan path dan URL yang benar
- ✅ Tombol "Terima/Tolak Pembayaran" tersedia
- ✅ CORS headers diterapkan untuk akses dari frontend

**Backend API:**
- ✅ Response JSON include `payment_proof_url` dan `payment_status`
- ✅ URL menggunakan route custom yang reliable
- ✅ File served dengan Content-Type yang benar

---

**Status:** ✅ Fixed - No More 403!  
**Last Updated:** 2026-07-22  
**Tested On:** Windows 10 + PHP 8.x + Laravel 11
