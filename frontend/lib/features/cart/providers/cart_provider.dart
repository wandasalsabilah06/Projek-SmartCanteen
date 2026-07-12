import 'package:flutter/foundation.dart';
import '../../menu/models/menu_item.dart';
import '../models/cart_item.dart';
import '../../../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final bool _isSubmitting = false;
  String? _errorMessage;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get deliveryFee => subtotal > 0 ? 5000 : 0;
  double get tax => subtotal * 0.05;
  double get totalAmount => subtotal + deliveryFee + tax;

  bool get isEmpty => _items.isEmpty;

  bool containsItem(int menuItemId) =>
      _items.any((item) => item.menuItem.id == menuItemId);

  int getQuantity(int menuItemId) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  void addItem(MenuItem menuItem, {int quantity = 1, String? note}) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (index >= 0) {
      final current = _items[index];
      final newQty = (current.quantity + quantity).clamp(
        1,
        AppConstants.maxCartItemQuantity,
      );
      _items[index] = current.copyWith(quantity: newQty);
    } else {
      _items.add(CartItem(menuItem: menuItem, quantity: quantity, note: note));
    }
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void updateQuantity(int menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: quantity.clamp(1, AppConstants.maxCartItemQuantity),
      );
      notifyListeners();
    }
  }

  void increment(int menuItemId) {
    final qty = getQuantity(menuItemId);
    updateQuantity(menuItemId, qty + 1);
  }

  void decrement(int menuItemId) {
    final qty = getQuantity(menuItemId);
    updateQuantity(menuItemId, qty - 1);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
