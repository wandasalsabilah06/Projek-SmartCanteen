import 'package:flutter/foundation.dart';
import '../../menu/models/menu_item.dart';
import '../models/cart_item.dart';
import '../../../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  bool containsItem(String menuItemId) =>
      _items.any((item) => item.menuItem.id == menuItemId);

  int getQuantity(String menuItemId) {
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

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
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

  void increment(String menuItemId) {
    final qty = getQuantity(menuItemId);
    updateQuantity(menuItemId, qty + 1);
  }

  void decrement(String menuItemId) {
    final qty = getQuantity(menuItemId);
    updateQuantity(menuItemId, qty - 1);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
