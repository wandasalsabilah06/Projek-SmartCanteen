#!/bin/bash

echo "========================================="
echo "FIX STORAGE UNTUK BUKTI TRANSFER"
echo "========================================="
echo ""

echo "[1/4] Membuat symbolic link storage..."
php artisan storage:link

echo ""
echo "[2/4] Membuat folder payment_proofs jika belum ada..."
mkdir -p storage/app/public/payment_proofs

echo ""
echo "[3/4] Set permission folder storage..."
chmod -R 775 storage/
chmod -R 775 public/storage/ 2>/dev/null || true

echo ""
echo "[4/4] Mengecek hasil..."
if [ -L "public/storage" ]; then
    echo "[OK] Symbolic link berhasil dibuat"
else
    echo "[ERROR] Symbolic link gagal dibuat"
fi

if [ -d "storage/app/public/payment_proofs" ]; then
    echo "[OK] Folder payment_proofs sudah ada"
else
    echo "[ERROR] Folder payment_proofs gagal dibuat"
fi

echo ""
echo "========================================="
echo "Selesai!"
echo "========================================="
echo ""
echo "Test URL gambar:"
echo "http://localhost:8000/storage/payment_proofs/test.jpg"
echo ""
