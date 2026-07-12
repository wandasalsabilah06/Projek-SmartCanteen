import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      // Try to find order from already-loaded orders or use current order
      final current = orderProvider.currentOrder;
      if (current != null && current.id.toString() == widget.orderId) {
        setState(() => _order = current);
      } else {
        // Load user's orders to find this specific order
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          orderProvider.loadOrders(user.id).then((_) {
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
              setState(() => _order = found);
            }
          });
        }
      }
    });
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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header
        _AppHeader(order: order),
        const SizedBox(height: 16),

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
                      color: const Color(0xFF4CAF50),
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
                        const Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
              const Text(
                '12 mins left',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _getProgress(order.status),
                  backgroundColor: const Color(0xFFE8E0D8),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // "Order is ready" notification
        if (isReady)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
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
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.close, color: Colors.white70, size: 16),
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

  Widget _buildJourney(Order order) {
    final steps = [
      _JourneyStep(
        icon: Icons.check_rounded,
        label: 'Order Received',
        subtitle: '12:45 PM • Successfully confirmed',
        isCompleted: true,
        isActive: true,
      ),
      _JourneyStep(
        icon: Icons.restaurant_menu_rounded,
        label: 'Cooking Your Meal',
        subtitle:
            'Chef is preparing your ${order.details.isNotEmpty ? order.details.first.menuName : 'meal'}',
        isCompleted:
            order.status == OrderStatus.diproses ||
            order.status == OrderStatus.selesai,
        isActive: order.status == OrderStatus.diproses,
      ),
      _JourneyStep(
        icon: Icons.restaurant_rounded,
        label: 'Ready for Pickup',
        subtitle: 'Estimated by 1:05 PM',
        isCompleted: order.status == OrderStatus.selesai,
        isActive: false,
      ),
      _JourneyStep(
        icon: Icons.check_circle_outline_rounded,
        label: 'Order Collected',
        subtitle: 'Enjoy your meal!',
        isCompleted: false,
        isActive: false,
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
      case OrderStatus.dibatalkan:
        return 'Order Cancelled';
    }
  }

  double _getProgress(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.25;
      case OrderStatus.diproses:
        return 0.6;
      case OrderStatus.selesai:
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
