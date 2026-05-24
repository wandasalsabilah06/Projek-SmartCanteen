import 'package:equatable/equatable.dart';
import '../../menu/models/menu_item.dart';

class CartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;
  final String? note;

  const CartItem({required this.menuItem, required this.quantity, this.note});

  double get subtotal => menuItem.price * quantity;

  CartItem copyWith({MenuItem? menuItem, int? quantity, String? note}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [menuItem, quantity, note];
}
