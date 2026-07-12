# 🔄 Update Role User - Admin & Pelanggan

## ✅ Perubahan yang Dilakukan

Role user telah diubah dari **"admin/user"** menjadi **"admin/pelanggan"**

### 📝 Alasan Perubahan
Lebih jelas dan sesuai dengan konteks Smart Canteen:
- **Admin** = Pengelola sistem
- **Pelanggan** = Customer/pembeli (bukan "user" yang terlalu umum)

---

## 📁 File yang Diupdate

### 1. Views (3 files)
✅ **resources/views/admin/users/create.blade.php**
- Option role: admin / pelanggan

✅ **resources/views/admin/users/edit.blade.php**
- Option role: admin / pelanggan

✅ **resources/views/admin/users/index.blade.php**
- Display role: Admin / Pelanggan

### 2. Controller (1 file)
✅ **app/Http/Controllers/Admin/UserController.php**
- Validation: `in:admin,pelanggan` (di store & update method)

### 3. Seeder (1 file)
✅ **database/seeders/AdminSeeder.php**
- Sample user role diubah jadi 'pelanggan'

### 4. Documentation (5 files)
✅ **README_ADMIN.md**
✅ **CARA_MENGGUNAKAN_ADMIN.md**
✅ **SUMMARY_ADMIN_PANEL.txt**
✅ **CHECKLIST_ADMIN_PANEL.md**
✅ **COMMANDS.txt**

---

## 🎯 Implementasi

### Form Dropdown (Create & Edit User)
```html
<select name="role">
    <option value="">Pilih Role</option>
    <option value="admin">Admin</option>
    <option value="pelanggan">Pelanggan</option>
</select>
```

### Display Badge (List User)
```php
{{ $user->role == 'admin' ? 'Admin' : 'Pelanggan' }}
```

### Validation (Controller)
```php
'role' => 'required|in:admin,pelanggan'
```

---

## 🔐 Login Credentials (Setelah Re-seed)

### Admin
- Email: `admin@admin.com`
- Password: `password`
- Role: `admin`

### Pelanggan
- Email: `user@test.com`
- Password: `password`
- Role: `pelanggan`

---

## 🚀 Cara Menerapkan Update

### Opsi 1: Fresh Install (RECOMMENDED)
```bash
# Reset database dan seed ulang
php artisan migrate:fresh
php artisan db:seed --class=AdminSeeder
```

### Opsi 2: Update Data Existing
```bash
php artisan tinker
```
```php
// Update role dari 'user' ke 'pelanggan'
DB::table('users')->where('role', 'user')->update(['role' => 'pelanggan']);

// Atau update spesifik user
DB::table('users')->where('email', 'user@test.com')->update(['role' => 'pelanggan']);

exit
```

### Opsi 3: Manual via SQL
```sql
UPDATE users SET role = 'pelanggan' WHERE role = 'user';
```

---

## ✨ Hasil Akhir

### Di Form Input
```
Role: [Pilih Role ▼]
      - Admin
      - Pelanggan
```

### Di List User
```
| Nama      | Email           | Role               |
|-----------|-----------------|-------------------|
| Admin     | admin@admin.com | [Admin]    (merah)|
| User Test | user@test.com   | [Pelanggan] (biru)|
```

---

## ⚠️ Penting!

1. **Database harus di-reset** atau update manual jika ada data existing dengan role 'user'
2. **Validation sudah disesuaikan** - hanya accept 'admin' dan 'pelanggan'
3. **Dokumentasi sudah update** semua

---

## 🧪 Testing

### Test Create User
1. Buka http://localhost:8000/admin/users/create
2. Pilih role "Pelanggan"
3. Submit form
4. ✅ Berhasil dengan role 'pelanggan'

### Test Edit User
1. Edit user existing
2. Dropdown hanya menampilkan "Admin" dan "Pelanggan"
3. ✅ User lama (role 'user') masih bisa diedit

### Test List
1. Buka http://localhost:8000/admin/users
2. Badge menampilkan "Admin" atau "Pelanggan"
3. ✅ Display text jelas dan user-friendly

---

## 📊 Perbandingan

### SEBELUM
```
Role Options: admin | user
Display: Admin | User
Validation: in:admin,user
```

### SESUDAH
```
Role Options: admin | pelanggan
Display: Admin | Pelanggan
Validation: in:admin,pelanggan
```

---

## ✅ Status: COMPLETE

Role user berhasil diubah menjadi **Admin** dan **Pelanggan**! 🎉

Refresh browser dan test di:
```
http://localhost:8000/admin/users
```
