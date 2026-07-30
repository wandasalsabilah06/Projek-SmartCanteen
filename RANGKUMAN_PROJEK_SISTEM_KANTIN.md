# 📋 RANGKUMAN LENGKAP PROJEK SISTEM KANTIN (SMART CANTEEN)

## 📌 INFORMASI UMUM PROJEK

### Nama Projek
**Smart Canteen System** - Sistem Pemesanan Kantin Digital

### Deskripsi Projek
Aplikasi mobile (Flutter) dan web admin (Laravel) untuk mengelola pemesanan makanan/minuman di kantin, dengan fitur pembayaran transfer bank dan verifikasi admin real-time.

### Teknologi yang Digunakan

#### **Frontend (Mobile App)**
- **Framework:** Flutter 3.x
- **State Management:** Provider
- **Routing:** go_router
- **HTTP Client:** Dio
- **Image Picker:** image_picker
- **Platform:** Android, iOS, Web

#### **Backend (API & Admin Panel)**
- **Framework:** Laravel 10.x
- **Database:** MySQL
- **Authentication:** Laravel Sanctum
- **Storage:** Laravel Storage (local disk)
- **Frontend Admin:** Blade Template + Bootstrap 5.3

---

## 🏗️ ARSITEKTUR SISTEM

### Struktur Projek

```
📁 root/
├── 📁 frontend/          # Flutter Mobile App
│   ├── 📁 lib/
│   │   ├── 📁 core/      # Konfigurasi, tema, router, network
│   │   ├── 📁 features/  # Fitur-fitur aplikasi
│   │   └── 📁 shared/    # Widget & screen bersama
│   └── 📁 assets/        # Logo, icon, gambar
│
├── 📁 backend/           # Laravel Backend
│   ├── 📁 app/           # Models, Controllers, Middleware
│   ├── 📁 database/      # Migrations, Seeders
│   ├── 📁 routes/        # API & Web routes
│   ├── 📁 resources/     # Views (Blade template)
│   ├── 📁 public/        # Public files & uploads
│   └── 📁 storage/       # File storage (payment proofs, logs)
│
└── 📄 Dokumentasi        # Markdown files (README, FLOW, FIX)
```

---

## 📊 DATABASE SCHEMA

### Tabel-Tabel Utama

#### 1. **users**
```
id, name, email, password, role (admin/pelanggan), timestamps
```

#### 2. **categories**
```
id, nama_kategori, target_jumlah_menu, timestamps
```

#### 3. **menus**
```
id, category_id, nama_menu, harga, stok, gambar, deskripsi, timestamps
```

#### 4. **orders**
```
id, user_id, tanggal_order, total_harga, status, 
payment_method, payment_proof, payment_verified_at, 
payment_verified_by, payment_rejection_reason, timestamps
```

#### 5. **order_details**
```
id, order_id, menu_id, qty, harga, subtotal, timestamps
```

### Relasi Database
- `users` → `orders` (1:N) - User memiliki banyak order
- `categories` → `menus` (1:N) - Kategori memiliki banyak menu
- `orders` → `order_details` (1:N) - Order memiliki banyak detail
- `menus` → `order_details` (1:N) - Menu dapat ada di banyak order
- `users` → `orders.payment_verified_by` (1:N) - Admin memverifikasi payment

---

## 🎯 FITUR-FITUR SISTEM

### A. MOBILE APP (FLUTTER)

#### 1. **Authentication**
- Login dengan email & password
- Validasi input
- Session management dengan SharedPreferences
- Auto-login jika token valid

#### 2. **Home Screen**
- Banner slider (gambar promosi)
- Kategori menu (horizontal scroll)
- Daftar menu dengan filter kategori
- Search menu
- Add to cart

#### 3. **Menu Management**
- Tampilan grid/list menu
- Detail menu (gambar, nama, harga, deskripsi, stok)
- Filter by kategori
- Indikator stok (tersedia/habis)

#### 4. **Shopping Cart**
- Tambah/kurang quantity
- Hapus item
- Tampilkan subtotal per item
- Total harga keseluruhan
- Badge counter di icon cart

#### 5. **Checkout**
- **Metode Pembayaran:**
  - Cash (bayar di kasir)
  - Transfer Bank
  - QRIS (future)
- Konfirmasi pesanan
- Create order via API
- Redirect ke Order Tracking

#### 6. **Order Tracking** (Fitur Utama!)
- **Status Order:**
  - Pending (menunggu)
  - Diproses (sedang dimasak)
  - Selesai (siap diambil)
  - Diambil (sudah diterima customer)
  - Dibatalkan
  
- **Payment Flow Transfer:**
  1. **Belum Upload** → Card Biru → Tombol "Upload Bukti Transfer"
  2. **Menunggu Verifikasi** → Card Orange → Loading indicator
  3. **Terverifikasi** → Card Hijau → Pesanan diproses
  4. **Ditolak** → Card Merah → Upload ulang + alasan penolakan
  
- **Auto-Refresh:** Setiap 10 detik cek status terbaru
- **Order Journey:** Progress bar (Pending → Cooking → Ready → Collected)
- **Konfirmasi Pengambilan:** Tombol "Sudah Diambil" untuk update status

#### 7. **Order History**
- Riwayat pesanan
- Filter: Active Orders & History
- Detail order dengan item list
- Status tracking

#### 8. **Profile**
- Informasi user
- Logout

---

### B. WEB ADMIN PANEL (LARAVEL)

#### 1. **Dashboard**
- Total Users
- Total Kategori
- Total Menu
- Total Orders
- Orders Pending (widget)

#### 2. **User Management**
- CRUD User (Create, Read, Update, Delete)
- Set role: admin / pelanggan
- Validasi email unik

#### 3. **Category Management**
- CRUD Kategori
- Field: nama_kategori, target_jumlah_menu
- Validasi: kategori tidak bisa dihapus jika masih ada menu

#### 4. **Menu Management**
- CRUD Menu
- Upload gambar (jpg/png/gif, max 2MB)
- Field: kategori, nama_menu, harga, stok, deskripsi
- Indikator stok (hijau > 10, kuning 1-10, merah = 0)
- Auto-convert JFIF ke JPG

#### 5. **Order Management**
- View semua orders dengan pagination
- Detail order (user info, items, total, status)
- Update status order:
  - Pending → Diproses → Selesai → Diambil
  - Dibatalkan
- Tambah/hapus item order
- Auto-calculate total harga
- Auto-update stok menu

#### 6. **Payment Verification** (Transfer Bank)
- **View Bukti Transfer:**
  - Preview gambar
  - Path & URL debug info
  - Modal zoom gambar
  - Link "Buka di tab baru"
  
- **Verifikasi Pembayaran:**
  - **Terima:** Set payment_verified_at, payment_verified_by
  - **Tolak:** Input alasan penolakan, reset verification
  
- **Status Badge:**
  - Belum Upload (abu-abu)
  - Menunggu Verifikasi (kuning)
  - Terverifikasi (hijau)
  - Ditolak (merah)

---

## 🔄 ALUR BISNIS PROSES

### 1. ALUR CUSTOMER (MOBILE APP)

```
📱 LOGIN
  ↓
🏠 HOME - Browse Menu
  ↓ (Pilih menu)
🛒 ADD TO CART
  ↓ (Checkout)
💳 PILIH METODE PEMBAYARAN
  ├─ Cash → Order Created → Tracking
  └─ Transfer → Order Created → Upload Bukti
                    ↓
📸 UPLOAD BUKTI TRANSFER
  ↓
⏳ MENUNGGU VERIFIKASI (auto-refresh)
  ↓
  ├─ Admin APPROVE → ✅ Terverifikasi → Tracking
  └─ Admin REJECT → ❌ Ditolak → Upload Ulang
                    ↓
📊 ORDER TRACKING
  ↓
Pending → Diproses → Selesai (Ready)
  ↓
✅ KONFIRMASI "SUDAH DIAMBIL"
  ↓
✓ DIAMBIL (Completed)
```

---

### 2. ALUR ADMIN (WEB PANEL)

```
🔐 LOGIN ADMIN
  ↓
📊 DASHBOARD
  ↓
👥 KELOLA DATA:
  ├─ Users
  ├─ Kategori
  ├─ Menu (upload gambar)
  └─ Orders
      ↓
📦 ORDER DETAIL
  ↓
💳 VERIFIKASI PAYMENT TRANSFER
  ├─ Lihat Bukti Transfer
  ├─ Terima → Update payment_verified_at
  └─ Tolak → Input alasan penolakan
      ↓
📊 UPDATE STATUS ORDER
  Pending → Diproses → Selesai
      ↓
✅ CUSTOMER AMBIL PESANAN
  (Customer konfirmasi di app)
      ↓
✓ STATUS "DIAMBIL"
```

---

## 🔌 API ENDPOINTS

### Authentication
```
POST /api/login
- Body: { email, password }
- Response: { token, user }
```

### Menu
```
GET  /api/menus
GET  /api/menus/{id}
```

### Orders
```
POST /api/orders
- Body: { user_id, total_harga, payment_method, items[] }
- Response: { message, order }

GET  /api/orders/user/{userId}
GET  /api/orders/{id}

POST /api/orders/{id}/upload-payment-proof
- Body: FormData { payment_proof: file }
- Response: { message, payment_proof_url }
```

### Image Proxy
```
GET /api/image/{path}
- CORS enabled untuk Flutter Web
```

---

## 💾 STORAGE & FILE MANAGEMENT

### Lokasi File Upload

#### Menu Images
```
backend/public/uploads/menus/
- Format: timestamp_filename.jpg
- Akses: http://localhost:8000/uploads/menus/xxx.jpg
```

#### Payment Proofs
```
backend/storage/app/public/payment_proofs/
- Symbolic link: public/storage → storage/app/public
- Akses: http://localhost:8000/storage/payment_proofs/xxx.jpg
```

### Setup Storage
```bash
# Buat symbolic link
php artisan storage:link

# Test storage
php artisan storage:test

# Fix permission (Linux/Mac)
chmod -R 775 storage/
chmod -R 775 public/storage/
```

---

## 🎨 UI/UX DESIGN

### Mobile App (Flutter)

#### Color Scheme
```dart
Primary: #FF6B35 (Orange)
Secondary: #F7931E
Background: #F5F5F5
Text Primary: #212121
Text Secondary: #757575
```

#### Komponen UI
- AppBar dengan gradient
- Card untuk menu items
- Bottom Navigation Bar
- Modal Bottom Sheet untuk cart
- Floating Action Button
- Snackbar untuk notifikasi
- Progress Indicator
- Badge counter

### Web Admin (Laravel)

#### Framework UI
- Bootstrap 5.3
- Bootstrap Icons
- Custom CSS

#### Layout
- Sidebar navigation (kiri)
- Top navbar dengan user info
- Content area (tengah)
- Card-based design
- Responsive design

---

## 🔐 SECURITY & VALIDATION

### Frontend (Flutter)
- Input validation (email format, required fields)
- Token-based authentication
- Secure storage (SharedPreferences)
- Image validation (file type, size)

### Backend (Laravel)
- Form validation (Laravel Request)
- SQL injection protection (Eloquent ORM)
- CSRF protection (Blade forms)
- File upload validation:
  - Type: jpg, jpeg, png, gif
  - Size: max 2MB
- Role-based access (admin/pelanggan)
- Foreign key constraints

---

## 🧪 TESTING & DEBUGGING

### Testing Flow Payment Transfer
```
✅ Upload bukti transfer dari Flutter
✅ File tersimpan di storage/app/public/payment_proofs/
✅ Symbolic link berfungsi
✅ Gambar muncul di admin panel
✅ Admin dapat melihat preview gambar
✅ Admin dapat approve/reject
✅ Status update real-time di Flutter (10 detik)
✅ Customer menerima notifikasi status
```

### Debug Tools
- **Flutter:** debugPrint, Chrome DevTools
- **Laravel:** dd(), Log::debug(), Laravel Debugbar
- **API Testing:** Postman, Thunder Client
- **Database:** phpMyAdmin, MySQL Workbench

### Common Issues & Fixes
1. **Gambar tidak muncul** → `php artisan storage:link`
2. **CORS error** → Middleware CorsStaticFiles
3. **Upload gagal** → Check file size & type
4. **Auto-refresh tidak berjalan** → Check Timer.periodic
5. **Payment status tidak berubah** → Check accessor di Model

---

## 📦 DEPLOYMENT & SETUP

### Requirements
- **Frontend:** Flutter SDK 3.x, Android Studio / VS Code
- **Backend:** PHP 8.1+, Composer, MySQL 5.7+, Laravel 10.x

### Setup Backend
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed --class=AdminSeeder
php artisan storage:link
php artisan serve
```

### Setup Frontend
```bash
cd frontend
flutter pub get
flutter run
```

### Default Credentials
**Admin:**
- Email: admin@admin.com
- Password: password

**User:**
- Email: user@test.com
- Password: password

---

## 📈 STATISTIK PROJEK

### File Count
- **Backend:** ~150 files (PHP, Blade, Config)
- **Frontend:** ~50 files (Dart, Assets)
- **Total Lines of Code:** ~10,000+ lines

### Features Implemented
- ✅ 8 fitur mobile app
- ✅ 6 fitur admin panel
- ✅ 5 API endpoints group
- ✅ 5 database tables dengan relasi
- ✅ Payment verification flow (4 status)
- ✅ Real-time status update (polling)
- ✅ File upload (menu images + payment proofs)
- ✅ Auto-refresh mechanism
- ✅ Stock management system
- ✅ Order journey tracking

---

## 🚀 FUTURE ENHANCEMENTS (OPTIONAL)

### Planned Features
1. **Dashboard Admin dengan Statistik:**
   - Total pendapatan per bulan
   - Pendapatan per kategori menu
   - Pendapatan per tahun
   - Top selling menu
   - Chart visualisasi

2. **Notifikasi Real-time:**
   - Push notification (Firebase)
   - WebSocket untuk instant update
   - Email notification untuk admin

3. **Payment Gateway Integration:**
   - QRIS (LinkAja, GoPay, OVO)
   - Virtual Account
   - E-wallet integration

4. **Advanced Features:**
   - Promo & discount system
   - Loyalty points
   - Rating & review menu
   - Multi-outlet support
   - Report generation (PDF/Excel)

---

## 📝 DOKUMENTASI TAMBAHAN

### File Dokumentasi yang Ada
1. `README.md` - Overview projek
2. `README_ADMIN.md` - Panduan admin panel
3. `CARA_MENGGUNAKAN_ADMIN.md` - Tutorial lengkap admin
4. `FLOW_PEMBAYARAN_TRANSFER.md` - Flow payment transfer
5. `FIX_GAMBAR_BUKTI_TRANSFER.md` - Troubleshooting gambar
6. `FIX_ERROR.md` - Error fixes
7. `UPDATE_*.md` - Update log fitur

---

## 👥 TIM PENGEMBANG

### Role & Responsibility
- **Backend Developer:** Laravel API, Admin Panel, Database
- **Frontend Developer:** Flutter Mobile App, UI/UX
- **Full Stack:** Integration, Testing, Deployment

---

## 📞 SUPPORT & MAINTENANCE

### Maintenance Checklist
- ✅ Database backup (daily/weekly)
- ✅ Storage cleanup (old payment proofs)
- ✅ Log monitoring (Laravel logs)
- ✅ Security updates (Composer, Flutter)
- ✅ API performance monitoring
- ✅ User feedback collection

---

## ✅ KESIMPULAN

Projek **Smart Canteen System** adalah aplikasi pemesanan kantin digital yang lengkap dengan:
- Mobile app (Flutter) untuk customer
- Web admin panel (Laravel) untuk pengelola
- Payment verification system (Transfer Bank)
- Real-time order tracking
- Stock management otomatis
- Upload & verify payment proof

Sistem ini siap digunakan untuk kantin sekolah, universitas, atau perusahaan dengan flow pemesanan yang modern dan efisien.

---

**Dokumen ini dibuat untuk keperluan laporan projek.**

**Tanggal:** 28 Juli 2026  
**Versi:** 1.0  
**Status:** ✅ Production Ready
