import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Single HTTP client for the Proxim Shelf backend.
/// All mobile data/auth goes through here — never call Firebase from the app.
///
/// Android emulator: 10.0.2.2:8080
/// iOS simulator / desktop: localhost:8080
/// Override: --dart-define=API_BASE=http://YOUR_HOST:8080
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://0.0.0.0:8080',
  );

  String? _token;

  // ── Token persistence 
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _handle(http.Response res) async {
    final decoded = jsonDecode(res.body.isEmpty ? '{}' : res.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      return body;
    }
    final err = body['error'];
    final message = err is Map
        ? (err['message']?.toString() ?? 'Request failed')
        : (body['message']?.toString() ?? 'Request failed');
    throw Exception(message);
  }

  Future<List<dynamic>> _handleList(http.Response res) async {
    final decoded = jsonDecode(res.body.isEmpty ? '{}' : res.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = body['data'];
      if (data is List) return data;
      return [];
    }
    final err = body['error'];
    final message = err is Map
        ? (err['message']?.toString() ?? 'Request failed')
        : 'Request failed';
    throw Exception(message);
  }

  // ── Auth ─────────────
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );
    final data = await _handle(res);
    final token = data['token']?.toString();
    if (token != null) await saveToken(token);
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handle(res);
    final token = data['token']?.toString();
    if (token != null) await saveToken(token);
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: _headers,
    );
    return _handle(res);
  }

  // ── Providers ────────
  Future<List<dynamic>> listProviders({
    String? category,
    String? city,
    bool onlineOnly = false,
  }) async {
    final q = <String, String>{};
    if (category != null && category.isNotEmpty) q['category'] = category;
    if (city != null && city.isNotEmpty) q['city'] = city;
    if (onlineOnly) q['online'] = 'true';
    final uri = Uri.parse('$baseUrl/api/providers')
        .replace(queryParameters: q.isEmpty ? null : q);
    final res = await http.get(uri, headers: _headers);
    return _handleList(res);
  }

  Future<Map<String, dynamic>> getProvider(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/providers/$id'),
      headers: _headers,
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> upsertProviderProfile(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/providers/profile'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> setOnline(bool isOnline) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/api/providers/online'),
      headers: _headers,
      body: jsonEncode({'isOnline': isOnline}),
    );
    return _handle(res);
  }

  // ── Jobs ─────────────
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/jobs'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handle(res);
  }

  Future<List<dynamic>> listJobs({String? status}) async {
    final uri = status != null
        ? Uri.parse('$baseUrl/api/jobs')
            .replace(queryParameters: {'status': status})
        : Uri.parse('$baseUrl/api/jobs');
    final res = await http.get(uri, headers: _headers);
    return _handleList(res);
  }

  Future<Map<String, dynamic>> getJob(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/jobs/$id'),
      headers: _headers,
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateJobStatus(
    String id,
    String status, {
    String? note,
  }) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/api/jobs/$id/status'),
      headers: _headers,
      body: jsonEncode({
        'status': status,
        if (note != null) 'note': note,
      }),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> rateJob(
    String id,
    int rating, {
    String? review,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/jobs/$id/rate'),
      headers: _headers,
      body: jsonEncode({
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
      }),
    );
    return _handle(res);
  }

  // ── Wallet ───────────
  Future<Map<String, dynamic>> getWallet() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/wallet'),
      headers: _headers,
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> topUp(
    double amount, {
    String? reference,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/wallet/topup'),
      headers: _headers,
      body: jsonEncode({
        'amount': amount,
        if (reference != null) 'reference': reference,
      }),
    );
    return _handle(res);
  }

  Future<List<dynamic>> transactions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/wallet/transactions'),
      headers: _headers,
    );
    return _handleList(res);
  }
}
