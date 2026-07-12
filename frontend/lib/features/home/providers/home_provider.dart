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

  /// 4 menu pertama sebagai "popular"
  List<MenuItem> get popular => _allMenus.take(4).toList();

  /// Semua menu tersedia sebagai "recommended"
  List<MenuItem> get recommended =>
      _allMenus.where((m) => m.isAvailable).toList();

  List<MenuItem> get filteredMenus {
    if (_selectedCategoryId == 0) return _allMenus;
    return _allMenus.where((m) => m.categoryId == _selectedCategoryId).toList();
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await ApiClient.instance.dio.get('/menus');
      final list = resp.data as List<dynamic>;
      _allMenus = list
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Bangun kategori unik dari data menu — tidak butuh endpoint /categories
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
          'HomeProvider: loaded ${_allMenus.length} menus, '
          '${_categories.length} categories',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint('HomeProvider.loadHomeData error: $e');
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
