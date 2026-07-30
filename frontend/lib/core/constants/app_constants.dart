import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'SmartCanteen';
  static const String appVersion = '1.0.0';

  // ── IP Backend ────────────────────────────────────────────────────────────
  // Jalankan backend dengan: php artisan serve --host=0.0.0.0 --port=8000
  //
  // Ganti sesuai kondisi:
  //   Android Device Fisik  → IP LAN komputer (cek dengan `ipconfig`)
  //   Android Emulator      → 10.0.2.2
  //   Browser/Web           → localhost (otomatis)
  static const String _deviceIp = '10.167.140.64';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    return 'http://$_deviceIp:8000/api';
  }

  static String get imageBaseUrl {
    if (kIsWeb) return 'http://localhost:8000/';
    return 'http://$_deviceIp:8000/';
  }

  // Timeout lebih longgar untuk jaringan WiFi lokal
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_done';

  static const int defaultPageSize = 10;
  static const int maxCartItemQuantity = 99;

  static const String placeholderFood =
      'https://placehold.co/300x200/F3EFEA/B0A79D?text=No+Image';
  static const String placeholderAvatar =
      'https://placehold.co/100x100/F3EFEA/B0A79D?text=User';
}
