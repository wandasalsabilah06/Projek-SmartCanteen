-- Jalankan SQL ini langsung di phpMyAdmin atau MySQL client
-- Untuk menambahkan status 'diambil' ke ENUM tanpa hapus data

ALTER TABLE orders 
MODIFY COLUMN status ENUM('pending', 'diproses', 'selesai', 'diambil', 'dibatalkan') 
DEFAULT 'pending';
