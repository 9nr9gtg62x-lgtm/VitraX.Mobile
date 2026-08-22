import 'package:flutter/material.dart';
import '../services/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  String? error;
  bool isBusy = false;

  Future<void> restoreSession() async {
    await ApiClient.instance.loadToken();
    status = ApiClient.instance.isAuthenticated
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      await ApiClient.instance.login(username, password);
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      await ApiClient.instance.register(username, password);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.logout();
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
