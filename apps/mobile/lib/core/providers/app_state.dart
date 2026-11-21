import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService api = ApiService();

  Map<String, dynamic>? user;
  bool loading = true;
  bool showSplash = true;
  bool onboardingDone = false;
  String? error;

  /// Demo customer "current" location (Port Harcourt centre) for proximity sort.
  static const double userLat = 4.8156;
  static const double userLng = 7.0498;

  bool get isLoggedIn => user != null;
  bool get isProvider => user?['role'] == 'provider';
  bool get isCustomer => user?['role'] == 'customer';

  Future<void> init() async {
    loading = true;
    showSplash = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      onboardingDone = prefs.getBool('onboarding_done') ?? false;

      // Brief splash for polish (max ~1s) + session restore in parallel
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 900)),
        _restoreSession(),
      ]);
    } catch (_) {
      user = null;
    } finally {
      loading = false;
      showSplash = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    try {
      await api.loadToken();
      if (!api.hasToken) {
        user = null;
        return;
      }
      user = await api.me();
    } catch (_) {
      user = null;
      await api.clearToken();
    }
  }

  Future<void> completeOnboarding() async {
    onboardingDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    error = null;
    notifyListeners();
    try {
      user = await api.login(email: email, password: password);
      notifyListeners();
    } catch (e) {
      error = _clean(e);
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
      error = _clean(e);
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

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '').replaceFirst('TimeoutException after', 'Server timed out');
}
