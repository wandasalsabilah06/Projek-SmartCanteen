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
  if (!raw.startsWith('http')) {
    final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
    return '${AppConstants.baseUrl}/image/$cleaned';
  }
  // Ganti localhost/127.0.0.1 ke IP yang benar agar bisa diakses dari HP
  final uri = Uri.tryParse(raw);
  if (uri != null &&
      (uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '10.0.2.2')) {
    final base = Uri.parse(AppConstants.imageBaseUrl);
    return uri
        .replace(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
        )
        .toString();
  }
  return raw;
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

enum OrderStatus { pending, diproses, selesai, diambil, dibatalkan }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.diambil:
        return 'Diambil';
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
      case 'diambil':
        return OrderStatus.diambil;
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
  final String paymentMethod;
  final String? paymentProofUrl;
  final DateTime? paymentVerifiedAt;
  final String? paymentRejectionReason;
  final String paymentStatus;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.totalHarga,
    required this.status,
    required this.tanggalOrder,
    this.details = const [],
    this.paymentMethod = 'cash',
    this.paymentProofUrl,
    this.paymentVerifiedAt,
    this.paymentRejectionReason,
    this.paymentStatus = 'belum_upload',
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
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentProofUrl: json['payment_proof_url'] as String?,
      paymentVerifiedAt: json['payment_verified_at'] != null
          ? DateTime.tryParse(json['payment_verified_at'] as String)
          : null,
      paymentRejectionReason: json['payment_rejection_reason'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'belum_upload',
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        totalHarga,
        paymentProofUrl,
        paymentVerifiedAt,
        paymentStatus,
      ];
}
