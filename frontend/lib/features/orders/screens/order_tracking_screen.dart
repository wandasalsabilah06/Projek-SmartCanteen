import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/orders/providers/order_provider.dart';
import '../models/order.dart';
import '../../../shared/widgets/app_network_image.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Order? _order;
  Timer? _refreshTimer;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
      // Auto refresh setiap 10 detik
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _loadOrder();
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final orderProvider = context.read<OrderProvider>();
    final user = context.read<AuthProvider>().user;
    
    if (user == null) return;
    
    try {
      // Prioritaskan load dari API detail untuk mendapatkan payment_status terbaru
      final orderId = int.tryParse(widget.orderId) ?? 0;
      final detailOrder = await orderProvider.getOrderDetail(orderId);
      
      if (detailOrder != null && mounted) {
        if (kDebugMode) {
          debugPrint('=== Order Loaded ===');
          debugPrint('Order ID: ${detailOrder.id}');
          debugPrint('Payment Status: ${detailOrder.paymentStatus}');
          debugPrint('Order Status: ${detailOrder.status.label}');
        }
        
        // Update state DULU sebelum show dialog
        setState(() => _order = detailOrder);
        
        // Cek jika payment ditolak dan order belum diproses
        if (detailOrder.paymentStatus == 'ditolak' && 
            detailOrder.status == OrderStatus.pending) {
          // Tampilkan dialog rejection
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRejectionDialog(detailOrder.paymentRejectionReason);
          });
        }
        
        // Stop auto-refresh jika order sudah diambil atau dibatalkan
        if (detailOrder.status == OrderStatus.diambil || 
            detailOrder.status == OrderStatus.dibatalkan) {
          _refreshTimer?.cancel();
          if (kDebugMode) {
            debugPrint('Auto-refresh stopped (order completed/cancelled)');
          }
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading order detail: $e');
      }
    }
    
    // Fallback: load dari list orders jika getOrderDetail gagal
    try {
      await orderProvider.loadOrders(user.id);
      
      if (mounted) {
        final found = orderProvider.orders.firstWhere(
          (o) => o.id.toString() == widget.orderId,
          orElse: () => orderProvider.orders.isNotEmpty
              ? orderProvider.orders.first
              : Order(
                  id: int.tryParse(widget.orderId) ?? 0,
                  orderNumber: 'SC-${widget.orderId}',
                  userId: user.id,
                  userName: user.name,
                  totalHarga: 0,
                  status: OrderStatus.pending,
                  tanggalOrder: DateTime.now(),
                ),
        );

        if (kDebugMode) {
          debugPrint('=== Order Loaded (Fallback) ===');
          debugPrint('Order ID: ${found.id}');
          debugPrint('Payment Status: ${found.paymentStatus}');
        }

        // Update state DULU
        setState(() => _order = found);

        // Cek jika payment ditolak
        if (found.paymentStatus == 'ditolak' && 
            found.status == OrderStatus.pending) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRejectionDialog(found.paymentRejectionReason);
          });
        }
        
        // Stop auto-refresh jika order sudah diambil atau dibatalkan
        if (found.status == OrderStatus.diambil || 
            found.status == OrderStatus.dibatalkan) {
          _refreshTimer?.cancel();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading orders: $e');
      }
    }
  }

  void _showRejectionDialog(String? reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFEF5350),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pembayaran Ditolak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin telah menolak bukti transfer Anda dengan alasan:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF9800),
                ),
              ),
              child: Text(
                reason ?? 'Tidak ada alasan diberikan',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan upload ulang bukti transfer yang benar atau hubungi admin untuk bantuan.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
            child: const Text(
              'Kembali ke Home',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Tetap di halaman ini untuk upload ulang
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Upload Ulang'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPaymentProof() async {
    if (_order == null) return;

    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() => _isUploading = true);

      if (kDebugMode) {
        debugPrint('=== Starting payment proof upload ===');
        debugPrint('Order ID: ${_order!.id}');
        debugPrint('Current payment status: ${_order!.paymentStatus}');
      }

      final orderProvider = context.read<OrderProvider>();
      final success = await orderProvider.uploadPaymentProof(
        _order!.id,
        image.path,
      );

      if (!mounted) return;

      setState(() => _isUploading = false);

      if (success) {
        if (kDebugMode) {
          debugPrint('✓ Upload success! Reloading order...');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Bukti transfer berhasil diupload'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Reload order untuk mendapatkan status terbaru
        // Ini akan memicu setState dan UI akan berubah otomatis ke halaman "Menunggu Persetujuan"
        await _loadOrder();
        
        if (kDebugMode) {
          debugPrint('Order reloaded. New payment status: ${_order?.paymentStatus}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('✗ Upload failed');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Gagal upload bukti transfer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking/uploading image: $e');
      }
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Terjadi kesalahan saat memilih gambar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _order == null
            ? _buildLoading()
            : _buildContent(context, _order!),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        _AppHeader(),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Order order) {
    final isReady = order.status == OrderStatus.selesai;
    final isCollected = order.status == OrderStatus.diambil;
    final isTransfer = order.paymentMethod == 'transfer';
    final paymentVerified = order.paymentStatus == 'terverifikasi';
    final paymentPending = order.paymentStatus == 'menunggu_verifikasi';
    final paymentRejected = order.paymentStatus == 'ditolak';
    final paymentNotUploaded = order.paymentStatus == 'belum_upload';

    // Jika transfer dan belum verified, tampilkan halaman payment status saja
    if (isTransfer && !paymentVerified) {
      return _buildPaymentStatusPage(
        context, 
        order, 
        paymentNotUploaded, 
        paymentPending, 
        paymentRejected
      );
    }

    // Jika payment sudah verified atau bukan transfer, tampilkan halaman normal dengan order journey
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header
        _AppHeader(order: order),
        const SizedBox(height: 16),

        // Card Payment Approved (untuk transfer yang sudah verified)
        if (isTransfer && paymentVerified) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4CAF50),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pembayaran Disetujui',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Admin telah memverifikasi pembayaran Anda. Pesanan sedang diproses.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Status Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCollected 
                          ? const Color(0xFF2196F3)
                          : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCollected ? 'Completed' : 'Live',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isCollected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 12,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Auto refresh',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getStatusTitle(order.status),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (!isCollected)
                const Text(
                  '12 mins left',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              if (isCollected)
                const Text(
                  'Pesanan telah diambil',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _getProgress(order.status),
                  backgroundColor: const Color(0xFFE8E0D8),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCollected ? const Color(0xFF2196F3) : AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // "Order is ready" notification with confirm button
        if (isReady)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your order is ready!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Please head to Counter 4 for pickup.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Konfirmasi sudah diambil
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Pengambilan'),
                          content: const Text(
                            'Apakah Anda sudah mengambil pesanan ini di counter?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Belum'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sudah Diambil'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        if (context.mounted) {
                          // Show loading
                          final orderProvider = context.read<OrderProvider>();
                          
                          // Call API to update status to 'diambil'
                          final success = await orderProvider.confirmOrderCollected(_order!.id);
                          
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✓ Terima kasih! Selamat menikmati makanan Anda',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Reload order untuk update UI
                            await _loadOrder();
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✗ Gagal mengkonfirmasi pengambilan. Coba lagi.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text(
                      'Konfirmasi Sudah Diambil',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Completion message for collected orders
        if (isCollected)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan Selesai!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        'Terima kasih telah memesan. Selamat menikmati!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Order item preview
        if (order.details.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                AppNetworkImage(
                  imageUrl: order.details.first.menuImage,
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.details.first.menuName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.details.length > 1
                            ? '+${order.details.length - 1} more items'
                            : order.details.first.menuName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.toIDR(order.totalHarga),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Order Journey
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Order Journey',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildJourney(order),
        const SizedBox(height: 24),

        // Support card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.support_agent_rounded,
                size: 36,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Need help with your order?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Contact our support team if you have any questions about your current meal preparation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E0D8)),
                  ),
                  child: const Text(
                    'Contact Canteen Support',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPaymentStatusPage(
    BuildContext context,
    Order order,
    bool paymentNotUploaded,
    bool paymentPending,
    bool paymentRejected,
  ) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header
        _AppHeader(order: order),
        const SizedBox(height: 40),

        // Icon dan Status
        Center(
          child: Column(
            children: [
              // Icon Circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: paymentRejected
                      ? const Color(0xFFFFEBEE)
                      : paymentPending
                          ? const Color(0xFFFFF3E0)
                          : const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  paymentRejected
                      ? Icons.cancel_outlined
                      : paymentPending
                          ? Icons.schedule_rounded
                          : Icons.info_outline,
                  size: 64,
                  color: paymentRejected
                      ? const Color(0xFFEF5350)
                      : paymentPending
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                paymentRejected
                    ? 'Pembayaran Ditolak'
                    : paymentPending
                        ? 'Menunggu Persetujuan'
                        : 'Upload Bukti Transfer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: paymentRejected
                      ? const Color(0xFFD32F2F)
                      : paymentPending
                          ? const Color(0xFFF57C00)
                          : const Color(0xFF1976D2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  paymentRejected
                      ? 'Admin telah menolak bukti transfer Anda'
                      : paymentPending
                          ? 'Menunggu persetujuan admin.\nKami akan memverifikasi pembayaran Anda segera.'
                          : 'Silakan upload bukti transfer untuk melanjutkan pesanan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Rejection Reason
              if (paymentRejected && order.paymentRejectionReason != null) ...[
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alasan Penolakan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.paymentRejectionReason!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Detail Pembayaran Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Payment Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Menu', order.details.isNotEmpty ? order.details.first.menuName : '-'),
                    const Divider(height: 24),
                    _buildDetailRow('Metode', 'Transfer Bank'),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Status',
                      paymentRejected
                          ? 'Ditolak'
                          : paymentPending
                              ? 'Menunggu'
                              : 'Belum Upload',
                      valueColor: paymentRejected
                          ? const Color(0xFFEF5350)
                          : paymentPending
                              ? const Color(0xFFFF9800)
                              : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upload Button
              if (paymentRejected || paymentNotUploaded)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadPaymentProof,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload_file, size: 22),
                    label: Text(
                      _isUploading
                          ? 'Mengupload...'
                          : paymentRejected
                              ? 'Upload Ulang Bukti Transfer'
                              : 'Upload Bukti Transfer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              else if (paymentPending)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bukti transfer sedang diverifikasi oleh admin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildJourney(Order order) {
    final steps = [
      _JourneyStep(
        icon: Icons.check_rounded,
        label: 'Order Received',
        subtitle: '12:45 PM • Successfully confirmed',
        isCompleted: true,
        isActive: order.status == OrderStatus.pending,
      ),
      _JourneyStep(
        icon: Icons.restaurant_menu_rounded,
        label: 'Cooking Your Meal',
        subtitle:
            'Chef is preparing your ${order.details.isNotEmpty ? order.details.first.menuName : 'meal'}',
        isCompleted:
            order.status == OrderStatus.diproses ||
            order.status == OrderStatus.selesai ||
            order.status == OrderStatus.diambil,
        isActive: order.status == OrderStatus.diproses,
      ),
      _JourneyStep(
        icon: Icons.restaurant_rounded,
        label: 'Ready for Pickup',
        subtitle: 'Head to Counter 4',
        isCompleted: order.status == OrderStatus.selesai || order.status == OrderStatus.diambil,
        isActive: order.status == OrderStatus.selesai,
      ),
      _JourneyStep(
        icon: Icons.check_circle_outline_rounded,
        label: 'Order Collected',
        subtitle: 'Enjoy your meal!',
        isCompleted: order.status == OrderStatus.diambil,
        isActive: order.status == OrderStatus.diambil,
        isLast: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: steps.map((step) => _JourneyStepWidget(step: step)).toList(),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Orders',
                isActive: true,
                onTap: () => context.go(AppRoutes.orders),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                label: 'History',
                isActive: false,
                onTap: () => context.go(AppRoutes.history),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: false,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Received';
      case OrderStatus.diproses:
        return 'Cooking your meal';
      case OrderStatus.selesai:
        return 'Ready for Pickup';
      case OrderStatus.diambil:
        return 'Order Collected';
      case OrderStatus.dibatalkan:
        return 'Order Cancelled';
    }
  }

  double _getProgress(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.25;
      case OrderStatus.diproses:
        return 0.5;
      case OrderStatus.selesai:
        return 0.75;
      case OrderStatus.diambil:
        return 1.0;
      case OrderStatus.dibatalkan:
        return 0.0;
    }
  }
}

class _AppHeader extends StatelessWidget {
  final Order? order;
  const _AppHeader({this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final user = auth.user;
              return CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  (user?.firstName ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'SmartCanteen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _JourneyStep {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  _JourneyStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    this.isLast = false,
  });
}

class _JourneyStepWidget extends StatelessWidget {
  final _JourneyStep step;
  const _JourneyStepWidget({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: step.isCompleted || step.isActive
                    ? AppColors.primary
                    : const Color(0xFFF0EBE6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                color: step.isCompleted || step.isActive
                    ? Colors.white
                    : AppColors.textHint,
                size: 18,
              ),
            ),
            if (!step.isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted
                    ? AppColors.primary
                    : const Color(0xFFE8E0D8),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: step.isActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: step.isActive || step.isCompleted
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: step.isLast ? 0 : 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primary : const Color(0xFFB0A79D),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : const Color(0xFFB0A79D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
