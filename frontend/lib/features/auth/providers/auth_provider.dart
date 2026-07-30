import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userKey);
      if (userJson != null) {
        final decoded = jsonDecode(userJson) as Map<String, dynamic>;
        _user = User.fromJson(decoded);
        _status = AuthStatus.authenticated;
        ApiClient.instance.initialize();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      ApiClient.instance.initialize();

      if (kDebugMode) {
        debugPrint('Register → POST ${AppConstants.baseUrl}/register');
        debugPrint('       name: $name');
        debugPrint('       email: $email');
      }

      final response = await ApiClient.instance.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final userMap = data['user'] as Map<String, dynamic>;
      _user = User.fromJson(userMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Register DioException:');
        debugPrint('  type    : ${e.type}');
        debugPrint('  message : ${e.message}');
        debugPrint('  response: ${e.response?.data}');
        debugPrint('  url     : ${e.requestOptions.uri}');
      }

      final body = e.response?.data;
      String msg;

      switch (e.type) {
        case DioExceptionType.connectionError:
          msg =
              'Tidak dapat terhubung ke server.\n'
              'Pastikan backend berjalan dan HP/komputer satu jaringan WiFi.';
          break;
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          msg = 'Koneksi timeout. Periksa jaringan WiFi dan coba lagi.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 422) {
            // Validation errors
            if (body is Map && body['errors'] != null) {
              final errors = body['errors'] as Map<String, dynamic>;
              final firstError = errors.values.first;
              msg = firstError is List && firstError.isNotEmpty
                  ? firstError.first.toString()
                  : body['message']?.toString() ?? 'Data tidak valid';
            } else {
              msg = body is Map && body['message'] != null
                  ? body['message'].toString()
                  : 'Data tidak valid';
            }
          } else {
            msg = body is Map && body['message'] != null
                ? body['message'].toString()
                : 'Server error (${e.response?.statusCode})';
          }
          break;
        default:
          msg = body is Map && body['message'] != null
              ? body['message'].toString()
              : 'Terjadi kesalahan. Coba lagi.';
      }

      _errorMessage = msg;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Register unexpected: $e');
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Selalu reinit agar baseUrl terbaru dipakai
      ApiClient.instance.initialize();

      if (kDebugMode) {
        debugPrint('Login → POST ${AppConstants.baseUrl}/login');
        debugPrint('       email: $email');
      }

      final response = await ApiClient.instance.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final userMap = data['user'] as Map<String, dynamic>;
      _user = User.fromJson(userMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Login DioException:');
        debugPrint('  type    : ${e.type}');
        debugPrint('  message : ${e.message}');
        debugPrint('  response: ${e.response?.data}');
        debugPrint('  url     : ${e.requestOptions.uri}');
      }

      final body = e.response?.data;
      String msg;

      switch (e.type) {
        case DioExceptionType.connectionError:
          msg =
              'Tidak dapat terhubung ke server.\n'
              'Pastikan:\n'
              '• Backend berjalan (php artisan serve --host=0.0.0.0 --port=8000)\n'
              '• HP dan komputer satu jaringan WiFi\n'
              '• Firewall Windows mengizinkan port 8000';
          break;
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          msg = 'Koneksi timeout. Periksa jaringan WiFi dan coba lagi.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            msg = body is Map && body['message'] != null
                ? body['message'].toString()
                : 'Email atau password salah';
          } else {
            msg = body is Map && body['message'] != null
                ? body['message'].toString()
                : 'Server error (${e.response?.statusCode})';
          }
          break;
        default:
          msg = body is Map && body['message'] != null
              ? body['message'].toString()
              : 'Terjadi kesalahan. Coba lagi.';
      }

      _errorMessage = msg;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Login unexpected: $e');
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
