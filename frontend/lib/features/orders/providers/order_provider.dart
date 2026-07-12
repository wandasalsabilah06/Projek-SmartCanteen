import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<Order> _orders = [];
  Order? _currentOrder;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;

  List<Order> get activeOrders => _orders
      .where(
        (o) =>
            o.status == OrderStatus.pending || o.status == OrderStatus.diproses,
      )
      .toList();

  List<Order> get historyOrders => _orders
      .where(
        (o) =>
            o.status == OrderStatus.selesai ||
            o.status == OrderStatus.dibatalkan,
      )
      .toList();

  Future<void> loadOrders(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gunakan endpoint yang benar: /orders/user/{userId}
      final response = await ApiClient.instance.dio.get('/orders/user/$userId');
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      _orders = list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _orders = [];
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint('OrderProvider.loadOrders error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder({
    required AuthProvider authProvider,
    required CartProvider cartProvider,
  }) async {
    if (authProvider.user == null) return null;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = cartProvider.items
          .map(
            (ci) => {
              'menu_id': ci.menuItem.id,
              'qty': ci.quantity,
              'harga': ci.menuItem.price,
              'subtotal': ci.subtotal,
            },
          )
          .toList();

      final response = await ApiClient.instance.dio.post(
        '/orders',
        data: {
          'user_id': authProvider.user!.id,
          'total_harga': cartProvider.subtotal,
          'items': items,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final orderData = responseData['order'] as Map<String, dynamic>;
      _currentOrder = Order.fromJson(orderData);
      _orders.insert(0, _currentOrder!);
      cartProvider.clear();
      notifyListeners();
      return _currentOrder;
    } catch (e) {
      _errorMessage = 'Gagal membuat order. Coba lagi.';
      if (kDebugMode) debugPrint('OrderProvider.placeOrder error: $e');
      notifyListeners();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
