import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

// ── Parse helpers ─────────────────────────────────────────────────────────────
double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

String _resolveImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) {
    return AppConstants.placeholderFood;
  }
  if (raw.startsWith('http')) return raw;
  final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
  return '${AppConstants.baseUrl}/image/$cleaned';
}

// ─────────────────────────────────────────────────────────────────────────────

class OrderDetailItem extends Equatable {
  final int id;
  final int menuId;
  final String menuName;
  final String menuImage;
  final int qty;
  final double harga;
  final double subtotal;

  const OrderDetailItem({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.menuImage,
    required this.qty,
    required this.harga,
    required this.subtotal,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu'] as Map<String, dynamic>?;
    return OrderDetailItem(
      id: _toInt(json['id']),
      menuId: _toInt(json['menu_id']),
      menuName: (menu?['nama_menu'] as String?) ?? '',
      menuImage: _resolveImageUrl(menu?['gambar'] as String?),
      qty: _toInt(json['qty']),
      harga: _toDouble(json['harga']),
      subtotal: _toDouble(json['subtotal']),
    );
  }

  @override
  List<Object?> get props => [id, menuId, qty];
}

// ─────────────────────────────────────────────────────────────────────────────

enum OrderStatus { pending, diproses, selesai, dibatalkan }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  static OrderStatus fromString(String v) {
    switch (v.toLowerCase()) {
      case 'diproses':
        return OrderStatus.diproses;
      case 'selesai':
        return OrderStatus.selesai;
      case 'dibatalkan':
        return OrderStatus.dibatalkan;
      default:
        return OrderStatus.pending;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class Order extends Equatable {
  final int id;
  final String orderNumber;
  final int userId;
  final String userName;
  final double totalHarga;
  final OrderStatus status;
  final DateTime tanggalOrder;
  final List<OrderDetailItem> details;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.totalHarga,
    required this.status,
    required this.tanggalOrder,
    this.details = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['order_details'] as List<dynamic>? ?? [];
    return Order(
      id: _toInt(json['id']),
      orderNumber: 'SC-${json['id']}',
      userId: _toInt(json['user_id']),
      userName: (json['user'] as Map?)?['name'] as String? ?? '',
      totalHarga: _toDouble(json['total_harga']),
      status: OrderStatusX.fromString(json['status'] as String? ?? ''),
      tanggalOrder: json['tanggal_order'] != null
          ? DateTime.tryParse(json['tanggal_order'] as String) ?? DateTime.now()
          : DateTime.now(),
      details: rawDetails
          .map((e) => OrderDetailItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, status, totalHarga];
}
