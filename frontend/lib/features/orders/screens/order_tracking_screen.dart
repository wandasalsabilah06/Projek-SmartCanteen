import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #$orderId', style: AppTextStyles.heading2),
            const SizedBox(height: 24),
            _TrackingStep(
              status: OrderStatus.confirmed,
              label: 'Order Confirmed',
              isCompleted: true,
              isActive: false,
            ),
            _TrackingStep(
              status: OrderStatus.preparing,
              label: 'Preparing Your Food',
              isCompleted: true,
              isActive: true,
            ),
            _TrackingStep(
              status: OrderStatus.ready,
              label: 'Ready to Pick Up',
              isCompleted: false,
              isActive: false,
            ),
            _TrackingStep(
              status: OrderStatus.completed,
              label: 'Completed',
              isCompleted: false,
              isActive: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final OrderStatus status;
  final String label;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  const _TrackingStep({
    required this.status,
    required this.label,
    required this.isCompleted,
    required this.isActive,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isActive
        ? AppColors.primary
        : AppColors.textHint;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : isActive
                  ? const Icon(Icons.circle, color: Colors.white, size: 10)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primary : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
