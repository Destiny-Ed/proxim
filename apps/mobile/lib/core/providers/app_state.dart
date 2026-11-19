import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService api = ApiService();

  Map<String, dynamic>? user;
  bool loading = true;
  String? error;

  bool get isLoggedIn => user != null;
  bool get isProvider => user?['role'] == 'provider';
  bool get isCustomer => user?['role'] == 'customer';

  Future<void> init() async {
    loading = true;
    notifyListeners();
    try {
      await api.loadToken();
      user = await api.me();
    } catch (_) {
      user = null;
      await api.clearToken();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    error = null;
    notifyListeners();
    try {
      user = await api.login(email: email, password: password);
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    error = null;
    notifyListeners();
    try {
      user = await api.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await api.clearToken();
    user = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
