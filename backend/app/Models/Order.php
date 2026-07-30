<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id',
        'tanggal_order',
        'total_harga',
        'status',
        'payment_method',
        'payment_proof',
        'payment_verified_at',
        'payment_verified_by',
        'payment_rejection_reason'
    ];

    protected $casts = [
        'payment_verified_at' => 'datetime',
    ];

    protected $appends = [
        'payment_proof_url',
        'payment_status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orderDetails()
    {
        return $this->hasMany(OrderDetail::class);
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'payment_verified_by');
    }

    public function getPaymentProofUrlAttribute()
    {
        if ($this->payment_proof) {
            // Gunakan URL route untuk serve file (lebih reliable di php artisan serve)
            $filename = basename($this->payment_proof);
            return url("storage/payment_proofs/{$filename}");
        }
        return null;
    }

    public function getPaymentStatusAttribute()
    {
        if (!$this->payment_proof) {
            return 'belum_upload';
        }
        
        if ($this->payment_rejection_reason) {
            return 'ditolak';
        }
        
        if ($this->payment_verified_at) {
            return 'terverifikasi';
        }
        
        return 'menunggu_verifikasi';
    }
}
