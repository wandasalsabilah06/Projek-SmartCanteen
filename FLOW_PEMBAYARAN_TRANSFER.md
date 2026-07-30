# Flow Pembayaran Transfer - Testing & Verification

## 📱 Flow Lengkap dari Customer (Flutter)

### **1. Checkout & Order Creation**
```
Customer memilih metode: Transfer Bank
  ↓
Klik "Konfirmasi Pesanan"
  ↓
Order dibuat dengan:
- payment_method = 'transfer'
- payment_proof = null
- payment_verified_at = null
- payment_rejection_reason = null
- status = 'pending'
  ↓
Redirect ke Order Tracking Screen
```

### **2. Upload Bukti Transfer (Card Biru)**
```
Card: "Upload Bukti Transfer" (BIRU)
- Icon: info_outline
- Background: #E3F2FD (light blue)
- Border: #2196F3 (blue)
- Tombol: "Upload Bukti Transfer"

Customer klik tombol upload
  ↓
Pilih gambar dari galeri (image_picker)
  ↓
Loading: "Mengupload..." (button disabled)
  ↓
Upload ke: POST /api/orders/{id}/upload-payment-proof
  ↓
Backend:
- Simpan file ke storage/app/public/payment_proofs/
- Update order:
  - payment_proof = 'payment_proofs/xxx.jpg'
  - payment_verified_at = null (reset)
  - payment_verified_by = null (reset)
  - payment_rejection_reason = null (reset)
  ↓
Frontend:
✓ Notifikasi: "Bukti transfer berhasil diupload"
✓ Auto-reload order (getOrderDetail)
✓ payment_status berubah menjadi 'menunggu_verifikasi'
```

### **3. Menunggu Verifikasi (Card Orange) ⏳**
```
Card: "Menunggu Persetujuan Admin" (ORANGE)
- Icon: hourglass_empty
- Background: #FFF3E0 (light orange)
- Border: #FF9800 (orange)
- TIDAK ADA tombol upload
- Loading indicator kecil
- Text: "Bukti transfer Anda sedang diverifikasi oleh admin"
- Auto-refresh setiap 10 detik

Status di backend:
- payment_proof = 'payment_proofs/xxx.jpg' ✓
- payment_verified_at = null
- payment_rejection_reason = null
→ payment_status = 'menunggu_verifikasi'
```

### **4a. Admin APPROVE ✅ (Scenario Sukses)**
```
Admin di dashboard:
1. Buka Orders → Detail Order #X
2. Lihat bukti transfer di card "Pembayaran Transfer"
3. Klik "Terima Pembayaran"
   ↓
Backend update:
- payment_verified_at = now()
- payment_verified_by = admin_id
- payment_rejection_reason = null
   ↓
Auto-refresh Flutter (dalam 10 detik)
   ↓
payment_status berubah menjadi 'terverifikasi'
   ↓

Card: "Pembayaran Disetujui" (HIJAU) ✓
- Icon: check_circle
- Background: #E8F5E9 (light green)
- Border: #4CAF50 (green)
- Text: "Admin telah memverifikasi pembayaran Anda"
- Text: "Pesanan sedang diproses"
- TIDAK ADA tombol upload
   ↓
Scroll ke bawah:
Card hilang, muncul "Status Banner" + "Order Journey"
- Progress bar
- Journey steps: Pending → Cooking → Ready → Collected
- Status order bisa diupdate admin: pending → diproses → selesai → diambil
```

### **4b. Admin REJECT ❌ (Scenario Ditolak)**
```
Admin di dashboard:
1. Buka Orders → Detail Order #X
2. Lihat bukti transfer di card "Pembayaran Transfer"
3. Klik "Tolak Pembayaran"
4. Isi alasan penolakan
   ↓
Backend update:
- payment_verified_at = null
- payment_verified_by = null
- payment_rejection_reason = "alasan dari admin"
   ↓
Auto-refresh Flutter (dalam 10 detik)
   ↓
payment_status berubah menjadi 'ditolak'
   ↓

Card: "Pembayaran Ditolak" (MERAH)
- Icon: cancel_outlined
- Background: #FFEBEE (light red)
- Border: #EF5350 (red)
- Tampilkan alasan penolakan dalam box
- Tombol: "Upload Ulang Bukti"
   ↓
PLUS: Dialog auto-popup
- Title: "Pembayaran Ditolak"
- Content: Alasan penolakan
- Button 1: "Kembali ke Home" → context.go(AppRoutes.home)
- Button 2: "Upload Ulang" → tetap di halaman ini
   ↓
Jika upload ulang:
- Kembali ke step 2 (Card Biru)
- Upload file baru
- Backend reset verification
- Kembali ke step 3 (Card Orange)
```

## 🎨 Kondisi Card Payment

| payment_status | payment_proof | verified_at | rejection_reason | Card Color | Icon | Tombol | Auto-refresh |
|----------------|---------------|-------------|------------------|------------|------|--------|--------------|
| `belum_upload` | null | null | null | 🔵 BIRU | info | Upload | ✅ Ya |
| `menunggu_verifikasi` | ada | null | null | 🟠 ORANGE | hourglass | ❌ Tidak ada | ✅ Ya |
| `terverifikasi` | ada | ada | null | 🟢 HIJAU | check | ❌ Tidak ada | ✅ Ya |
| `ditolak` | ada | null | ada | 🔴 MERAH | cancel | Upload Ulang | ✅ Ya |

## ✅ Checklist Testing

### Frontend (Flutter)
- [ ] Card biru muncul saat pertama kali (payment_status = 'belum_upload')
- [ ] Tombol upload membuka galeri
- [ ] Loading indicator muncul saat upload
- [ ] Notifikasi "Bukti transfer berhasil diupload" muncul
- [ ] Card otomatis berubah menjadi orange setelah upload
- [ ] Card orange TIDAK menampilkan tombol upload
- [ ] Auto-refresh berjalan setiap 10 detik
- [ ] Card berubah menjadi hijau saat admin approve
- [ ] Card hijau menampilkan pesan "Pembayaran Disetujui"
- [ ] Order journey muncul setelah payment verified
- [ ] Dialog rejection muncul saat admin tolak
- [ ] Tombol "Upload Ulang" berfungsi di card merah
- [ ] Status order terupdate saat admin ubah status

### Backend (Laravel)
- [ ] Upload endpoint: `/api/orders/{id}/upload-payment-proof` berfungsi
- [ ] File tersimpan di `storage/app/public/payment_proofs/`
- [ ] Symbolic link `public/storage` sudah dibuat (`php artisan storage:link`)
- [ ] Gambar muncul di admin dashboard detail order
- [ ] Button "Terima Pembayaran" berfungsi
- [ ] Button "Tolak Pembayaran" berfungsi
- [ ] Modal penolakan muncul dengan form alasan
- [ ] Status payment berubah setelah approve/reject
- [ ] API `/api/orders/{id}` mengembalikan payment_status yang benar

## 🔄 Auto-Refresh Mechanism

```dart
// Refresh timer setiap 10 detik
_refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
  _loadOrder();
});

// Stop refresh saat order selesai
if (order.status == OrderStatus.diambil || 
    order.status == OrderStatus.dibatalkan) {
  _refreshTimer?.cancel();
}
```

## 🎯 Expected Behavior

### Saat Upload Berhasil:
1. ✅ Notifikasi sukses
2. ✅ Card LANGSUNG berubah dari biru → orange
3. ✅ Tombol upload HILANG
4. ✅ Loading indicator kecil muncul
5. ✅ Auto-refresh berjalan

### Saat Admin Approve:
1. ✅ Card berubah dari orange → hijau (dalam 10 detik)
2. ✅ Pesan "Pembayaran Disetujui"
3. ✅ Order journey muncul
4. ✅ Status order bisa diupdate

### Saat Admin Reject:
1. ✅ Card berubah dari orange → merah (dalam 10 detik)
2. ✅ Dialog rejection muncul otomatis
3. ✅ Alasan penolakan ditampilkan
4. ✅ Tombol "Upload Ulang" tersedia

## 🐛 Troubleshooting

### Card tidak berubah setelah upload
- Cek console: `debugPrint('Order updated. Payment status: ${order.paymentStatus}')`
- Cek network: API `/api/orders/{id}` mengembalikan payment_status
- Cek backend: `payment_verified_at` dan `payment_rejection_reason` harus null

### Gambar tidak muncul di admin
- Cek symbolic link: `php artisan storage:link`
- Cek permission folder `storage/`
- Test URL langsung: `http://localhost/storage/payment_proofs/xxx.jpg`

### Auto-refresh tidak berjalan
- Cek `_refreshTimer` tidak null
- Cek `mounted` sebelum setState
- Cek console untuk error

### Dialog rejection tidak muncul
- Cek kondisi: `paymentStatus == 'ditolak' && status == OrderStatus.pending`
- Cek `WidgetsBinding.instance.addPostFrameCallback`
- Cek `_showRejectionDialog` dipanggil

## 📊 Payment Status Logic (Backend)

```php
public function getPaymentStatusAttribute()
{
    // 1. Belum upload
    if (!$this->payment_proof) {
        return 'belum_upload';
    }
    
    // 2. Ditolak (ada alasan penolakan)
    if ($this->payment_rejection_reason) {
        return 'ditolak';
    }
    
    // 3. Terverifikasi (ada tanggal verifikasi)
    if ($this->payment_verified_at) {
        return 'terverifikasi';
    }
    
    // 4. Default: Menunggu verifikasi
    return 'menunggu_verifikasi';
}
```

## ✨ Success Indicators

✅ Customer dapat upload bukti transfer  
✅ Card berubah otomatis setelah upload  
✅ Admin dapat melihat bukti transfer  
✅ Admin dapat approve/reject  
✅ Customer melihat perubahan status real-time  
✅ Order tracking berjalan setelah payment approved  
✅ Flow dari pending → diproses → selesai → diambil berfungsi  

---

**PENTING:** Auto-refresh 10 detik memastikan customer melihat perubahan status tanpa perlu refresh manual!
