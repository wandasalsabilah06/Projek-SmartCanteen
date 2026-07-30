# Test Payment Status API

## Test dengan curl atau browser

### 1. Test Get Order Detail
```bash
# Ganti {order_id} dengan ID order yang ada
curl http://localhost:8000/api/orders/{order_id}
```

**Expected Response:**
```json
{
  "id": 123,
  "user_id": 1,
  "total_harga": 17000,
  "status": "pending",
  "payment_method": "transfer",
  "payment_proof": "payment_proofs/xxx.jpg",
  "payment_verified_at": null,
  "payment_rejection_reason": null,
  "payment_proof_url": "http://localhost:8000/storage/payment_proofs/xxx.jpg",
  "payment_status": "menunggu_verifikasi"  ← HARUS ADA!
}
```

### 2. Test Upload Payment Proof
```bash
# Upload file
curl -X POST http://localhost:8000/api/orders/{order_id}/upload-payment-proof \
  -F "payment_proof=@/path/to/image.jpg"
```

**Expected Response:**
```json
{
  "message": "Bukti transfer berhasil diupload",
  "payment_proof_url": "http://localhost:8000/storage/payment_proofs/xxx.jpg"
}
```

### 3. Verify After Upload
```bash
# Get order detail lagi
curl http://localhost:8000/api/orders/{order_id}
```

**Expected:**
- `payment_proof`: berisi path file
- `payment_status`: "menunggu_verifikasi"
- `payment_verified_at`: null
- `payment_rejection_reason`: null

## Quick Fix Applied

✅ Added `$appends` to Order model:
```php
protected $appends = [
    'payment_proof_url',
    'payment_status',
];
```

This ensures `payment_status` is included in JSON response automatically.
