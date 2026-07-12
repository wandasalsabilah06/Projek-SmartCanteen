import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/orders/models/order.dart';
import '../../../features/orders/providers/order_provider.dart';
import '../../../shared/widgets/app_network_image.dart';

class OrderHistoryScreen extends StatefulWidget {
  final bool showActive;
  const OrderHistoryScreen({super.key, this.showActive = false});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await context.read<OrderProvider>().loadOrders(user.id);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHistory = !widget.showActive;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      final u = auth.user;
                      return CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          (u?.firstName ?? 'U').substring(0, 1).toUpperCase(),
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
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Title ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isHistory ? 'Riwayat Pesanan' : 'Pesanan Aktif',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Search ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Cari pesanan...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, op, _) {
                  if (op.isLoading) return const _OrderSkeleton();

                  final all = isHistory ? op.historyOrders : op.activeOrders;
                  final filtered = _query.isEmpty
                      ? all
                      : all.where((o) {
                          return o.orderNumber.toLowerCase().contains(_query) ||
                              o.details.any(
                                (d) =>
                                    d.menuName.toLowerCase().contains(_query),
                              );
                        }).toList();

                  if (filtered.isEmpty) {
                    return _EmptyOrders(isHistory: isHistory);
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _OrderCard(order: filtered[i], isHistory: isHistory),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isHistory;
  const _OrderCard({required this.order, required this.isHistory});

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(order.status);
    final isCancelled = order.status == OrderStatus.dibatalkan;
    final firstDetail = order.details.isNotEmpty ? order.details.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: firstDetail != null
                    ? AppNetworkImage(
                        imageUrl: firstDetail.menuImage,
                        width: 70,
                        height: 70,
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFFF3EFEA),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.textHint,
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            firstDetail?.menuName ?? order.orderNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cfg.bg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cfg.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cfg.fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fmtDate(order.tanggalOrder),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (order.details.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        '+${order.details.length - 1} item lainnya',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3EFEA), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCancelled ? 'Direfund' : 'Total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.toIDR(order.totalHarga),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCancelled
                          ? AppColors.textHint
                          : AppColors.primary,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isCancelled)
                OutlinedButton(
                  onPressed: () => context.push(
                    AppRoutes.orderTrackingPath(order.id.toString()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFFDDD8D3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Detail'),
                )
              else
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pesan Lagi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  _SC _statusConfig(OrderStatus s) {
    switch (s) {
      case OrderStatus.selesai:
        return _SC(
          'Selesai',
          AppColors.statusCompleted,
          AppColors.statusCompletedText,
        );
      case OrderStatus.dibatalkan:
        return _SC(
          'Dibatalkan',
          AppColors.statusCancelled,
          AppColors.statusCancelledText,
        );
      case OrderStatus.diproses:
        return _SC(
          'Diproses',
          AppColors.statusProcessing,
          AppColors.statusProcessingText,
        );
      case OrderStatus.pending:
        return _SC(
          'Pending',
          AppColors.statusPending,
          AppColors.statusPendingText,
        );
    }
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year} • '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _SC {
  final String label;
  final Color bg;
  final Color fg;
  const _SC(this.label, this.bg, this.fg);
}

// ── Empty ─────────────────────────────────────────────────────────────────────
class _EmptyOrders extends StatelessWidget {
  final bool isHistory;
  const _EmptyOrders({required this.isHistory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 70,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 14),
          Text(
            isHistory ? 'Belum ada riwayat' : 'Tidak ada pesanan aktif',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pesan makanan favoritmu sekarang',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
            label: const Text('Lihat Menu'),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────
class _OrderSkeleton extends StatelessWidget {
  const _OrderSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFEEE8E2),
        highlightColor: const Color(0xFFF8F4F0),
        child: Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
