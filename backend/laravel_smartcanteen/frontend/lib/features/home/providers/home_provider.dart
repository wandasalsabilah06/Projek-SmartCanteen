import 'package:flutter/foundation.dart';
import '../../menu/models/menu_item.dart';
import '../../menu/models/category.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<MenuItem> _recommended = [];
  List<MenuItem> _popular = [];
  List<MenuCategory> _categories = [];
  String _selectedCategory = 'all';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MenuItem> get recommended => _recommended;
  List<MenuItem> get popular => _popular;
  List<MenuCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual repository calls
      await Future.delayed(const Duration(milliseconds: 800));
      _categories = MenuCategory.defaults;
      _recommended = _mockMenuItems();
      _popular = _mockMenuItems().reversed.toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  List<MenuItem> _mockMenuItems() => [
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
      isFeatured: true,
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
  ];
}
