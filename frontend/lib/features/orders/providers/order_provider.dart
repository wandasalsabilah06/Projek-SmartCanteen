import 'package:dio/dio.dart';
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
            o.status == OrderStatus.pending || 
            o.status == OrderStatus.diproses ||
            o.status == OrderStatus.selesai,
      )
      .toList();

  List<Order> get historyOrders => _orders
      .where(
        (o) =>
            o.status == OrderStatus.diambil ||
            o.status == OrderStatus.dibatalkan,
      )
      .toList();

  Future<void> loadOrders(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ApiClient.instance.initialize();
      final resp = await ApiClient.instance.dio.get('/orders/user/$userId');
      final data = resp.data;

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

      if (kDebugMode) {
        debugPrint(
          'OrderProvider: loaded ${_orders.length} orders for user $userId',
        );
      }
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
    String paymentMethod = 'cash',
  }) async {
    if (authProvider.user == null) return null;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ApiClient.instance.initialize();

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

      final resp = await ApiClient.instance.dio.post(
        '/orders',
        data: {
          'user_id': authProvider.user!.id,
          'total_harga': cartProvider.subtotal,
          'payment_method': paymentMethod,
          'items': items,
        },
      );

      final body = resp.data as Map<String, dynamic>;
      _currentOrder = Order.fromJson(body['order'] as Map<String, dynamic>);
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

  Future<bool> uploadPaymentProof(int orderId, String imagePath) async {
    try {
      ApiClient.instance.initialize();

      if (kDebugMode) {
        debugPrint('=== Uploading payment proof ===');
        debugPrint('Order ID: $orderId');
        debugPrint('Image path: $imagePath');
      }

      final formData = FormData.fromMap({
        'payment_proof': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await ApiClient.instance.dio.post(
        '/orders/$orderId/upload-payment-proof',
        data: formData,
      );

      if (kDebugMode) {
        debugPrint('✓ Upload response: ${response.data}');
      }

      // PENTING: Reload order detail setelah upload untuk mendapatkan payment_status terbaru
      if (kDebugMode) {
        debugPrint('Reloading order detail from API...');
      }
      
      final order = await getOrderDetail(orderId);
      
      if (order != null) {
        if (kDebugMode) {
          debugPrint('=== Order Detail Retrieved ===');
          debugPrint('Order ID: ${order.id}');
          debugPrint('Payment Method: ${order.paymentMethod}');
          debugPrint('Payment Proof URL: ${order.paymentProofUrl}');
          debugPrint('Payment Status: ${order.paymentStatus}');
          debugPrint('Payment Verified At: ${order.paymentVerifiedAt}');
          debugPrint('Payment Rejection: ${order.paymentRejectionReason}');
        }
        
        // Update order di list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = order;
          if (kDebugMode) {
            debugPrint('✓ Order updated in list at index $index');
          }
        }
        _currentOrder = order;
      } else {
        if (kDebugMode) {
          debugPrint('✗ Failed to get order detail after upload!');
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrderProvider.uploadPaymentProof error: $e');
        if (e is DioException) {
          debugPrint('DioException response: ${e.response?.data}');
          debugPrint('DioException status: ${e.response?.statusCode}');
        }
      }
      return false;
    }
  }

  Future<Order?> getOrderDetail(int orderId) async {
    try {
      ApiClient.instance.initialize();
      
      if (kDebugMode) {
        debugPrint('Fetching order detail for ID: $orderId');
      }
      
      final resp = await ApiClient.instance.dio.get('/orders/$orderId');
      
      if (kDebugMode) {
        debugPrint('Raw API response: ${resp.data}');
      }
      
      final order = Order.fromJson(resp.data as Map<String, dynamic>);
      
      if (kDebugMode) {
        debugPrint('✓ Order parsed successfully');
      }
      
      return order;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('✗ OrderProvider.getOrderDetail error: $e');
        if (e is DioException) {
          debugPrint('Response data: ${e.response?.data}');
          debugPrint('Status code: ${e.response?.statusCode}');
        }
      }
      return null;
    }
  }

  Future<bool> confirmOrderCollected(int orderId) async {
    try {
      ApiClient.instance.initialize();

      if (kDebugMode) {
        debugPrint('=== Confirming order collected ===');
        debugPrint('Order ID: $orderId');
      }

      final response = await ApiClient.instance.dio.post(
        '/orders/$orderId/confirm-collected',
      );

      if (kDebugMode) {
        debugPrint('✓ Confirm response: ${response.data}');
      }

      // Reload order detail untuk mendapatkan status terbaru
      final order = await getOrderDetail(orderId);
      
      if (order != null) {
        // Update order di list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = order;
          if (kDebugMode) {
            debugPrint('✓ Order updated in list. New status: ${order.status.label}');
          }
        }
        _currentOrder = order;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrderProvider.confirmOrderCollected error: $e');
        if (e is DioException) {
          debugPrint('DioException response: ${e.response?.data}');
          debugPrint('DioException status: ${e.response?.statusCode}');
        }
      }
      return false;
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
