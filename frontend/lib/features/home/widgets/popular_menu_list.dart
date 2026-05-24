import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/menu/models/menu_item.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/quantity_control.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/home_provider.dart';

class PopularMenuList extends StatelessWidget {
  const PopularMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              child: SectionHeader(
                title: 'Popular Menus',
                actionLabel: 'See All',
                onAction: () => context.push(AppRoutes.menuList),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              itemCount: provider.popular.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (context, index) {
                return _PopularMenuCard(item: provider.popular[index]);
              },
            ),
          ],
        );
      },
    );
  }
}

class _PopularMenuCard extends StatelessWidget {
  final MenuItem item;

  const _PopularMenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.menuDetailPath(item.id)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            AppNetworkImage(
              imageUrl: item.imageUrl,
              width: AppDimensions.popularItemImageSize,
              height: AppDimensions.popularItemImageSize,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBadge(rating: item.rating),
                      const SizedBox(width: 4),
                      Text(
                        '(${_formatReviewCount(item.reviewCount)} reviews)',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.toUSD(item.price),
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ),
            ),
            // Quantity Control
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                final qty = cart.getQuantity(item.id);
                if (qty == 0) {
                  return GestureDetector(
                    onTap: () => cart.addItem(item),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                }
                return QuantityControl(
                  quantity: qty,
                  onIncrement: () => cart.increment(item.id),
                  onDecrement: () => cart.decrement(item.id),
                  size: 28,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}
