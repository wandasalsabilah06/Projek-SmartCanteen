import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../providers/menu_provider.dart';

class MenuListScreen extends StatefulWidget {
  final String? category;

  const MenuListScreen({super.key, this.category});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenuItems(category: widget.category);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => context.read<MenuProvider>().search(value),
              decoration: const InputDecoration(
                hintText: 'Search your favorite meal...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MenuProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final items = provider.filteredItems;
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        Text('No menu found', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDimensions.paddingS),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () =>
                          context.push(AppRoutes.menuDetailPath(item.id)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL,
                          ),
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
                            AppNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 80,
                              height: 80,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  RatingBadge(rating: item.rating),
                                  const SizedBox(height: 6),
                                  Text(
                                    CurrencyFormatter.toUSD(item.price),
                                    style: AppTextStyles.priceSmall,
                                  ),
                                ],
                              ),
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cart, _) {
                                final qty = cart.getQuantity(item.id);
                                return GestureDetector(
                                  onTap: () => cart.addItem(item),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: qty > 0
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      qty > 0 ? Icons.check_rounded : Icons.add,
                                      color: qty > 0
                                          ? AppColors.primary
                                          : Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
