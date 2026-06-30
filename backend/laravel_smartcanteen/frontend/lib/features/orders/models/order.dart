import 'package:equatable/equatable.dart';
import '../../cart/models/cart_item.dart';

enum OrderStatus { pending, confirmed, preparing, ready, completed, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready to Pick Up';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final List<CartItem> items;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final String? note;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.note,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => CartItem(
              menuItem: e['menu_item'],
              quantity: e['quantity'] as int,
              note: e['note'] as String?,
            ),
          )
          .toList(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status, totalAmount, createdAt];
}
