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

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Pastikan ApiClient sudah diinit
      ApiClient.instance.initialize();

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
      // Baca pesan error dari response backend jika ada
      final responseData = e.response?.data;
      String msg;
      if (responseData is Map && responseData['message'] != null) {
        msg = responseData['message'].toString();
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        msg =
            'Tidak dapat terhubung ke server.\nPastikan backend berjalan di port 8000.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = 'Koneksi timeout. Coba lagi.';
      } else {
        msg = 'Email atau password salah';
      }

      if (kDebugMode) {
        debugPrint(
          'Login error: ${e.type} | ${e.message} | ${e.response?.data}',
        );
      }

      _errorMessage = msg;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Login unexpected error: $e');
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
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
