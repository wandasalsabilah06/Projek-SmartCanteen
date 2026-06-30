# Admin Panel - Laravel Smart Canteen

## 🚀 Instalasi & Setup

### 1. Install Dependencies
```bash
composer install
```

### 2. Setup Database
Edit file `.env` dan atur konfigurasi database:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=smartcanteen
DB_USERNAME=root
DB_PASSWORD=
```

### 3. Jalankan Migration & Seeder
```bash
php artisan migrate
php artisan db:seed --class=AdminSeeder
```

### 4. Jalankan Aplikasi
```bash
php artisan serve
```

Akses aplikasi di: `http://localhost:8000`

## 👤 Login Credentials

**Admin:**
- Email: `admin@admin.com`
- Password: `password`

**User:**
- Email: `user@test.com`
- Password: `password`
- Role: `pelanggan`

## 📋 Fitur Admin Panel

### 1. Dashboard
- Menampilkan statistik total users, kategori, menu, dan orders
- Widget untuk order pending
- Akses: `http://localhost:8000/admin/dashboard`

### 2. User Management
- CRUD User (Create, Read, Update, Delete)
- Set role (admin/pelanggan)
- Akses: `http://localhost:8000/admin/users`

### 3. Category Management
- CRUD Kategori menu
- Validasi: kategori tidak bisa dihapus jika masih memiliki menu
- Akses: `http://localhost:8000/admin/categories`

### 4. Menu Management
- CRUD Menu makanan/minuman
- Upload gambar menu
- Set harga, stok, dan deskripsi
- Akses: `http://localhost:8000/admin/menus`

### 5. Order Management
- Lihat semua orders
- Detail order dengan list item
- Update status order (pending, diproses, selesai, dibatalkan)
- Delete order
- Akses: `http://localhost:8000/admin/orders`

## 📁 Struktur File

```
app/
├── Http/Controllers/Admin/
│   ├── DashboardController.php
│   ├── UserController.php
│   ├── CategoryController.php
│   ├── MenuController.php
│   └── OrderController.php
└── Models/
    ├── User.php
    ├── Category.php
    ├── Menu.php
    ├── Order.php
    └── OrderDetail.php

resources/views/
├── layouts/
│   └── app.blade.php (Main layout dengan sidebar)
└── admin/
    ├── dashboard.blade.php
    ├── users/
    │   ├── index.blade.php
    │   ├── create.blade.php
    │   └── edit.blade.php
    ├── categories/
    │   ├── index.blade.php
    │   ├── create.blade.php
    │   └── edit.blade.php
    ├── menus/
    │   ├── index.blade.php
    │   ├── create.blade.php
    │   └── edit.blade.php
    └── orders/
        ├── index.blade.php
        └── show.blade.php

routes/
└── web.php (Admin routes dengan prefix 'admin')

database/
└── seeders/
    └── AdminSeeder.php (Data awal untuk testing)
```

## 🎨 Teknologi Frontend

- Bootstrap 5.3
- Bootstrap Icons
- Responsive design

## 📝 Notes

- Upload gambar menu disimpan di folder `public/uploads/menus/`
- Validasi form menggunakan Laravel validation
- Pagination untuk semua halaman list data
- Alert notification untuk setiap aksi (success/error)

## 🔒 Security

Untuk production, pastikan:
1. Ubah credentials default admin
2. Tambahkan middleware authentication
3. Set permission & authorization
4. Gunakan HTTPS
5. Validasi upload file dengan ketat
