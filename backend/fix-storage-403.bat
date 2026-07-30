@echo off
echo ================================================
echo FIX STORAGE 403 FORBIDDEN - SmartCanteen
echo ================================================
echo.

echo [1/4] Menghapus symbolic link lama (jika ada)...
if exist public\storage (
    rmdir public\storage
    echo OK - Link lama dihapus
) else (
    echo OK - Tidak ada link lama
)
echo.

echo [2/4] Membuat symbolic link baru...
php artisan storage:link
echo.

echo [3/4] Cek folder payment_proofs...
if not exist storage\app\public\payment_proofs (
    echo Membuat folder payment_proofs...
    mkdir storage\app\public\payment_proofs
    echo OK - Folder dibuat
) else (
    echo OK - Folder sudah ada
)
echo.

echo [4/4] Test akses file...
php artisan storage:test
echo.

echo ================================================
echo SELESAI!
echo ================================================
echo.
echo Coba buka: http://localhost:8000/storage/
echo.
echo Jika masih error 403:
echo 1. Pastikan backend berjalan: php artisan serve --host=0.0.0.0
echo 2. Cek .htaccess di public/
echo 3. Restart server
echo.
pause
