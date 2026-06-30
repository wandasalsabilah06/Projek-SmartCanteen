import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class MenuProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<MenuItem> _items = [];
  MenuItem? _selectedItem;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MenuItem> get items => _items;
  MenuItem? get selectedItem => _selectedItem;
  String get searchQuery => _searchQuery;

  List<MenuItem> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final query = _searchQuery.toLowerCase();
    return _items
        .where(
          (item) =>
              item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadMenuItems({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 600));
      _items = _mockItems();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMenuDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _selectedItem = _mockItems().firstWhere((item) => item.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  List<MenuItem> _mockItems() => [
    const MenuItem(
      id: '1',
      name: 'Mediterranean Bowl',
      description: 'Fresh quinoa, avocado, and chickpeas with tahini sauce.',
      price: 12.50,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      category: 'main_course',
      rating: 4.8,
      reviewCount: 320,
      isFeatured: true,
    ),
    const MenuItem(
      id: '2',
      name: 'Signature Burger',
      description: 'Premium beef patty with fresh vegetables and aged cheddar.',
      price: 15.00,
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      category: 'main_course',
      rating: 4.6,
      reviewCount: 210,
    ),
    const MenuItem(
      id: '3',
      name: 'Spicy Shio Ramen',
      description: 'Rich broth with tender noodles and soft-boiled egg.',
      price: 14.00,
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
      category: 'main_course',
      rating: 4.7,
      reviewCount: 1200,
    ),
    const MenuItem(
      id: '4',
      name: 'Berry Pancakes',
      description: 'Fluffy pancakes topped with fresh mixed berries.',
      price: 9.50,
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      category: 'desserts',
      rating: 4.9,
      reviewCount: 800,
    ),
    const MenuItem(
      id: '5',
      name: 'Mango Smoothie',
      description: 'Fresh mango blended with yogurt and honey.',
      price: 6.00,
      imageUrl:
          'https://images.unsplash.com/photo-1546173159-315724a31696?w=400',
      category: 'drinks',
      rating: 4.5,
      reviewCount: 450,
    ),
  ];
}
