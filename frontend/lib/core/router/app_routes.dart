class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String menuDetail = '/menu/:id';
  static const String menuList = '/menu';
  static const String cart = '/cart';
  static const String orderTracking = '/order/:id/tracking';

  // Helper to build dynamic routes
  static String menuDetailPath(String id) => '/menu/$id';
  static String orderTrackingPath(String id) => '/order/$id/tracking';
  static String menuListWithCategory(String category) =>
      '/menu?category=$category';
}
