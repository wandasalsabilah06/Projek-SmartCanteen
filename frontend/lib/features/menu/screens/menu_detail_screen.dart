import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../providers/menu_provider.dart';

class MenuDetailScreen extends StatefulWidget {
  final String menuId;
  const MenuDetailScreen({super.key, required this.menuId});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  int _qty = 1;
  bool _fav = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuDetail(int.parse(widget.menuId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<MenuProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) return const _DetailSkeleton();

          final item = prov.selectedItem;
          if (item == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Menu tidak ditemukan')),
            );
          }

          return Stack(
            children: [
              // ── Hero image ──────────────────────────────────────────────
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.44,
                width: double.infinity,
                child: AppNetworkImage(imageUrl: item.imageUrl),
              ),

              // ── Tombol back & favorite ──────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleBtn(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                      _CircleBtn(
                        icon: _fav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: _fav ? Colors.red : AppColors.textSecondary,
                        onTap: () => setState(() => _fav = !_fav),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom sheet ─────────────────────────────────────────────
              DraggableScrollableSheet(
                initialChildSize: 0.58,
                minChildSize: 0.53,
                maxChildSize: 0.92,
                builder: (ctx, scrollCtrl) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 130),
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDD8D3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Nama + rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.star,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Kategori badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: item.isAvailable
                                  ? AppColors.statusCompleted
                                  : AppColors.statusCancelled,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.isAvailable
                                  ? 'Tersedia (${item.stock})'
                                  : 'Habis',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: item.isAvailable
                                    ? AppColors.statusCompletedText
                                    : AppColors.statusCancelledText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Deskripsi
                      if (item.description.isNotEmpty) ...[
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const Divider(color: Color(0xFFF0EBE6)),
                      const SizedBox(height: 16),

                      // Pilih jumlah
                      Row(
                        children: [
                          const Text(
                            'Jumlah',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          _QtySelector(
                            qty: _qty,
                            onChanged: item.isAvailable
                                ? (v) => setState(() => _qty = v)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // ── Bottom bar ────────────────────────────────────────────────────────
      bottomNavigationBar: Consumer2<MenuProvider, CartProvider>(
        builder: (context, prov, cart, _) {
          final item = prov.selectedItem;
          if (item == null || prov.isLoading) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 14,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.toIDR(item.price * _qty),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.isAvailable
                              ? AppColors.primary
                              : AppColors.textHint,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: item.isAvailable
                            ? () {
                                cart.addItem(item, quantity: _qty);
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item.name} ditambahkan ke keranjang',
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(
                          Icons.shopping_basket_outlined,
                          size: 18,
                        ),
                        label: Text(
                          item.isAvailable
                              ? 'Tambah ke Keranjang'
                              : 'Menu Habis',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int qty;
  final ValueChanged<int>? onChanged;

  const _QtySelector({required this.qty, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyBtn(
          icon: Icons.remove,
          enabled: qty > 1 && onChanged != null,
          onTap: () => onChanged?.call(qty - 1),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _QtyBtn(
          icon: Icons.add,
          enabled: onChanged != null,
          onTap: () => onChanged?.call(qty + 1),
          filled: true,
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool filled;

  const _QtyBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled
              ? (enabled ? AppColors.primary : AppColors.textHint)
              : (enabled ? const Color(0xFFF0EBE6) : const Color(0xFFF8F6F4)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? Colors.white
              : (enabled ? AppColors.textPrimary : AppColors.textHint),
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEE8E2),
      highlightColor: const Color(0xFFF8F4F0),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.44,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 24, width: 220, color: Colors.white),
                const SizedBox(height: 12),
                Container(height: 16, width: 120, color: Colors.white),
                const SizedBox(height: 16),
                Container(height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 14, width: 280, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
