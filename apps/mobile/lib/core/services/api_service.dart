import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin HTTP client that talks ONLY to the Proxim Shelf backend.
/// Base URL defaults to localhost for development.
class ApiService {
  ApiService({this.baseUrl = 'http://localhost:8080'});

  final String baseUrl;
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _handle(http.Response res) async {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body is Map<String, dynamic>) return body;
      return {'data': body};
    }
    final message = body is Map ? (body['error'] ?? body['message'] ?? res.body) : res.body;
    throw Exception(message);
  }

  // ── Auth ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handle(res);
    if (data['token'] != null) setToken(data['token'] as String);
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        if (phone != null) 'phone': phone,
      }),
    );
    final data = await _handle(res);
    if (data['token'] != null) setToken(data['token'] as String);
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: _headers);
    return _handle(res);
  }

  // ── Providers ──────────────────────────────────────────────────────────
  Future<List<dynamic>> listProviders({
    String? category,
    String? location,
    String? query,
  }) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (location != null) params['location'] = location;
    if (query != null) params['q'] = query;
    final uri = Uri.parse('$baseUrl/providers').replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri, headers: _headers);
    final data = await _handle(res);
    return (data['data'] ?? data) as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getProvider(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/providers/$id'), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> createProvider(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/providers'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateProvider(String id, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/providers/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  // ── Jobs ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> listJobs({
    String? customerId,
    String? providerId,
    String? status,
  }) async {
    final params = <String, String>{};
    if (customerId != null) params['customerId'] = customerId;
    if (providerId != null) params['providerId'] = providerId;
    if (status != null) params['status'] = status;
    final uri = Uri.parse('$baseUrl/jobs').replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri, headers: _headers);
    final data = await _handle(res);
    return (data['data'] ?? data) as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getJob(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/jobs/$id'), headers: _headers);
    return _handle(res);
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/jobs'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateJob(String id, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/jobs/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> acceptJob(String id, String providerId, {String? note}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/jobs/$id/accept'),
      headers: _headers,
      body: jsonEncode({'providerId': providerId, if (note != null) 'note': note}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> startJob(String id, {String? note}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/jobs/$id/start'),
      headers: _headers,
      body: jsonEncode({if (note != null) 'note': note}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> completeJob(String id, {String? note}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/jobs/$id/complete'),
      headers: _headers,
      body: jsonEncode({if (note != null) 'note': note}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> cancelJob(String id, {String? note}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/jobs/$id/cancel'),
      headers: _headers,
      body: jsonEncode({if (note != null) 'note': note}),
    );
    return _handle(res);
  }

  // ── Wallet ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getWallet(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/wallet/$userId'), headers: _headers);
    return _handle(res);
  }

  Future<List<dynamic>> listTransactions(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/wallet/$userId/transactions'), headers: _headers);
    final data = await _handle(res);
    return (data['data'] ?? data) as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> fundWallet(String userId, double amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/wallet/$userId/fund'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
    return _handle(res);
  }
}
