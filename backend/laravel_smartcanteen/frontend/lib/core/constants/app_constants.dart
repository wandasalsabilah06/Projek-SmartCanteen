class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Smart Canteen';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.smartcanteen.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_done';

  // Pagination
  static const int defaultPageSize = 10;

  // Cart
  static const int maxCartItemQuantity = 99;

  // Image Placeholders
  static const String placeholderFood =
      'https://via.placeholder.com/300x200?text=Food';
  static const String placeholderAvatar =
      'https://via.placeholder.com/100x100?text=User';
}
