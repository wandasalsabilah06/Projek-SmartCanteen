import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/menu_item.dart';
import '../models/category.dart';

class MenuProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<MenuItem> _items = [];
  List<MenuCategory> _categories = [];
  MenuItem? _selectedItem;
  int _selectedCategoryId = 0;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MenuItem> get items => _items;
  List<MenuCategory> get categories => _categories;
  MenuItem? get selectedItem => _selectedItem;
  int get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<MenuItem> get filteredItems {
    var result = _items;
    if (_selectedCategoryId != 0) {
      result = result
          .where((i) => i.categoryId == _selectedCategoryId)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (i) =>
                i.name.toLowerCase().contains(q) ||
                i.description.toLowerCase().contains(q) ||
                i.categoryName.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  /// Bangun kategori dari data menu — tidak perlu endpoint terpisah
  void _buildCategories() {
    final map = <int, MenuCategory>{};
    for (final m in _items) {
      if (m.categoryId > 0 && !map.containsKey(m.categoryId)) {
        map[m.categoryId] = MenuCategory(
          id: m.categoryId,
          name: m.categoryName,
          icon: MenuCategory.iconForName(m.categoryName),
        );
      }
    }
    _categories = map.values.toList();
  }

  Future<void> loadMenuItems({int? categoryId, String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    if (categoryId != null) _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      ApiClient.instance.initialize();
      final resp = await ApiClient.instance.dio.get('/menus');
      final list = resp.data as List<dynamic>;
      _items = list
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _buildCategories();
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint('MenuProvider.loadMenuItems error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMenuDetail(int id) async {
    _isLoading = true;
    _selectedItem = null;
    notifyListeners();

    try {
      ApiClient.instance.initialize();
      final resp = await ApiClient.instance.dio.get('/menus/$id');
      _selectedItem = MenuItem.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint('MenuProvider.loadMenuDetail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
