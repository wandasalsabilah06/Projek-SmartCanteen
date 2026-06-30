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
import '../../../shared/widgets/rating_badge.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/home_provider.dart';

class RecommendedMenuList extends StatelessWidget {
  const RecommendedMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildSkeleton();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              child: SectionHeader(
                title: 'Recommended for You',
                actionLabel: 'See All',
                onAction: () => context.push(AppRoutes.menuList),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                itemCount: provider.recommended.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _RecommendedCard(item: provider.recommended[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) => Container(
          width: AppDimensions.menuCardWidth,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final MenuItem item;

  const _RecommendedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.menuDetailPath(item.id)),
      child: Container(
        width: AppDimensions.menuCardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AppNetworkImage(
                  imageUrl: item.imageUrl,
                  height: AppDimensions.menuCardImageHeight,
                  width: double.infinity,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusL),
                    topRight: Radius.circular(AppDimensions.radiusL),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: RatingBadge(rating: item.rating, compact: true),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
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
                  Text(
                    item.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.toUSD(item.price),
                        style: AppTextStyles.price,
                      ),
                      _AddToCartButton(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final MenuItem item;

  const _AddToCartButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final inCart = cart.containsItem(item.id);
        return GestureDetector(
          onTap: () {
            cart.addItem(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} added to cart'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: inCart ? AppColors.primaryLight : AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  inCart
                      ? Icons.check_rounded
                      : Icons.add_shopping_cart_rounded,
                  size: 14,
                  color: inCart ? AppColors.primary : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  inCart ? 'Added' : 'Add',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: inCart ? AppColors.primary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
