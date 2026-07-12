import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'SmartCanteen';
  static const String appVersion = '1.0.0';

  // ── Ganti IP di sini sesuai platform ─────────────────────────────────────
  // Flutter Web (browser)   : http://localhost:8000
  // Android Emulator        : http://10.0.2.2:8000
  // Android Device Fisik    : http://192.168.x.x:8000  ← ganti IP LAN kamu
  // iOS Simulator           : http://localhost:8000
  static const String _localIp = '10.0.2.2'; // ← ganti jika device fisik

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    return 'http://$_localIp:8000/api';
  }

  static String get imageBaseUrl {
    if (kIsWeb) return 'http://localhost:8000/';
    return 'http://$_localIp:8000/';
  }

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

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
