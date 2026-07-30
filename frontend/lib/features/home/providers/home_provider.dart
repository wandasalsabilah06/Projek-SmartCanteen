import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../menu/models/menu_item.dart';
import '../../menu/models/category.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<MenuItem> _allMenus = [];
  List<MenuCategory> _categories = [];
  int _selectedCategoryId = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedCategoryId => _selectedCategoryId;
  List<MenuCategory> get categories => _categories;
  bool get hasData => _allMenus.isNotEmpty;

  // Menu populer hanya untuk kategori "Semua" (id = 0)
  List<MenuItem> get popular {
    if (_selectedCategoryId != 0) return [];
    return _allMenus.take(4).toList();
  }
  
  List<MenuItem> get recommended => _allMenus.skip(4).take(6).toList();

  List<MenuItem> get filteredMenus {
    if (_selectedCategoryId == 0) return _allMenus;
    return _allMenus.where((m) => m.categoryId == _selectedCategoryId).toList();
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Re-init ApiClient agar baseUrl selalu fresh
      ApiClient.instance.initialize();

      if (kDebugMode) {
        debugPrint(
          'HomeProvider: loading from ${ApiClient.instance.dio.options.baseUrl}',
        );
      }

      final resp = await ApiClient.instance.dio.get('/menus');
      final list = resp.data as List<dynamic>;

      _allMenus = list
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Build kategori unik dari menu — tidak perlu endpoint /categories
      final catMap = <int, MenuCategory>{};
      for (final m in _allMenus) {
        if (m.categoryId > 0 && !catMap.containsKey(m.categoryId)) {
          catMap[m.categoryId] = MenuCategory(
            id: m.categoryId,
            name: m.categoryName,
            icon: MenuCategory.iconForName(m.categoryName),
          );
        }
      }
      _categories = catMap.values.toList();

      if (kDebugMode) {
        debugPrint(
          'HomeProvider: ${_allMenus.length} menus, ${_categories.length} categories',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint('HomeProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}
