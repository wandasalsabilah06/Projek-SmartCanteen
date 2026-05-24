import 'package:flutter/foundation.dart';
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

    // TODO: Check token from SharedPreferences
    await Future.delayed(const Duration(seconds: 2));

    // Mock: simulate logged in user
    _user = const User(
      id: '1',
      name: 'Budi Santoso',
      email: 'budi@example.com',
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Call auth repository
      await Future.delayed(const Duration(seconds: 1));
      _user = const User(
        id: '1',
        name: 'Budi Santoso',
        email: 'budi@example.com',
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // TODO: Clear token from SharedPreferences
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
