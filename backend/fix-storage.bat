@echo off
echo =========================================
echo FIX STORAGE UNTUK BUKTI TRANSFER
echo =========================================
echo.

echo [1/3] Membuat symbolic link storage...
php artisan storage:link

echo.
echo [2/3] Membuat folder payment_proofs jika belum ada...
if not exist "storage\app\public\payment_proofs" mkdir "storage\app\public\payment_proofs"

echo.
echo [3/3] Mengecek hasil...
if exist "public\storage" (
    echo [OK] Symbolic link berhasil dibuat
) else (
    echo [ERROR] Symbolic link gagal dibuat
    echo Silakan jalankan CMD sebagai Administrator
)

if exist "storage\app\public\payment_proofs" (
    echo [OK] Folder payment_proofs sudah ada
) else (
    echo [ERROR] Folder payment_proofs gagal dibuat
)

echo.
echo =========================================
echo Selesai!
echo =========================================
echo.
echo Test URL gambar:
echo http://localhost:8000/storage/payment_proofs/test.jpg
echo.
pause
