class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String menuDetail = '/menu/:id';
  static const String menuList = '/menu';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order/:id/tracking';
  static const String orderPickup = '/order/:id/pickup';

  // Helper to build dynamic routes
  static String menuDetailPath(String id) => '/menu/$id';
  static String orderTrackingPath(String id) => '/order/$id/tracking';
  static String orderPickupPath(String id) => '/order/$id/pickup';
  static String menuListWithCategory(String category) =>
      '/menu?category=$category';
}
