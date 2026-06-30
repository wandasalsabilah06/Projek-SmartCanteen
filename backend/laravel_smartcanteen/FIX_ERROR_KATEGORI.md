# 🔧 Fix Error: Column 'target_jumlah_menu' not found

## ❌ Error yang Terjadi

```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 
'target_jumlah_menu' in 'field list'
```

## ✅ Penyebab

Migration untuk menambahkan kolom `target_jumlah_menu` belum dijalankan.

## 🛠️ Solusi

### Langkah 1: Jalankan Migration
```bash
php artisan migrate
```

**Output yang benar:**
```
INFO  Running migrations.
2026_06_24_152453_add_target_jumlah_menu_to_categories_table .... DONE
```

### Langkah 2: Clear Cache
```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

### Langkah 3: Refresh Browser
- Tekan **Ctrl + F5** (hard refresh)
- Atau tutup dan buka ulang browser

### Langkah 4: Test Update Kategori
1. Buka http://localhost:8000/admin/categories
2. Klik edit pada kategori
3. Isi "Target Jumlah Menu"
4. Klik "Update"
5. ✅ Berhasil!

---

## 🔍 Verifikasi Database

Jika ingin memastikan kolom sudah ada:

### Via Tinker
```bash
php artisan tinker
```
```php
// Cek struktur tabel
Schema::hasColumn('categories', 'target_jumlah_menu');
// Output: true

// Lihat data kategori
Category::first();

exit
```

### Via SQL (MySQL)
```sql
DESCRIBE categories;

-- Atau
SHOW COLUMNS FROM categories;
```

**Output yang benar:**
```
+--------------------+--------------+------+-----+---------+
| Field              | Type         | Null | Key | Default |
+--------------------+--------------+------+-----+---------+
| id                 | bigint       | NO   | PRI | NULL    |
| nama_kategori      | varchar(255) | NO   |     | NULL    |
| target_jumlah_menu | int          | NO   |     | 0       |
| created_at         | timestamp    | YES  |     | NULL    |
| updated_at         | timestamp    | YES  |     | NULL    |
+--------------------+--------------+------+-----+---------+
```

---

## ⚠️ Troubleshooting

### Error: Migration not found
Pastikan file migration ada:
```bash
dir database\migrations\*target_jumlah_menu*
```

### Error: Migration already ran
```bash
# Rollback 1 migration terakhir
php artisan migrate:rollback --step=1

# Jalankan ulang
php artisan migrate
```

### Error: Table doesn't exist
```bash
# Reset database (HAPUS SEMUA DATA!)
php artisan migrate:fresh
php artisan db:seed --class=AdminSeeder
```

---

## ✅ Status: FIXED

Migration berhasil dijalankan! Kolom `target_jumlah_menu` sudah ada di database.

**Next Steps:**
1. Refresh browser (Ctrl+F5)
2. Test update kategori
3. Fitur target menu siap digunakan! 🎉
