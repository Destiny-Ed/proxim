import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../data_source.dart';

/// In-memory implementation of DataSource.
/// All data lives in maps — perfect for local demo / tests.
/// Swap to FirebaseDataSource via DATA_SOURCE=firebase env without changing handlers.
class MemoryDataSource implements DataSource {
  final _uuid = const Uuid();

  // ── Users ──────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, String> _tokens = {}; // token -> userId

  // ── Providers ──────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _providers = {};

  // ── Jobs / Requests ────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _jobs = {};

  // ── Wallet ─────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _wallets = {};
  final Map<String, List<Map<String, dynamic>>> _transactions = {};

  MemoryDataSource() {
    _seed();
  }

  void _seed() {
    // Demo customer
    final customerId = 'user_customer_1';
    _users[customerId] = {
      'id': customerId,
      'email': 'customer@proxim.ng',
      'password': 'password123',
      'name': 'Ada Okoro',
      'phone': '+2348012345678',
      'role': 'customer',
      'avatarUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    _wallets[customerId] = {
      'userId': customerId,
      'balance': 50000.0,
      'currency': 'NGN',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transactions[customerId] = [];

    // Demo provider 1
    final providerUserId = 'user_provider_1';
    _users[providerUserId] = {
      'id': providerUserId,
      'email': 'provider@proxim.ng',
      'password': 'password123',
      'name': 'Chidi Eze',
      'phone': '+2348098765432',
      'role': 'provider',
      'avatarUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final providerId = 'provider_1';
    _providers[providerId] = {
      'id': providerId,
      'userId': providerUserId,
      'displayName': 'Chidi Plumbing Co.',
      'bio': 'Licensed plumber with 8+ years experience across Port Harcourt. Fast response, quality work.',
      'categories': ['plumbing', 'pipe_repair', 'water_heater'],
      'location': 'Port Harcourt, Rivers',
      'rating': 4.8,
      'reviewCount': 42,
      'completedJobs': 156,
      'isVerified': true,
      'isAvailable': true,
      'hourlyRate': 5000.0,
      'portfolio': [
        {
          'id': 'port_1',
          'title': 'Kitchen sink replacement',
          'description': 'Full sink + faucet swap for a 3-bed flat in GRA.',
          'imageUrl': null,
          'completedAt': '2026-09-12',
        },
        {
          'id': 'port_2',
          'title': 'Burst pipe emergency',
          'description': 'Fixed major burst on 2nd floor within 45 minutes.',
          'imageUrl': null,
          'completedAt': '2026-10-03',
        },
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };
    _wallets[providerUserId] = {
      'userId': providerUserId,
      'balance': 125000.0,
      'currency': 'NGN',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transactions[providerUserId] = [];

    // Demo provider 2
    final providerUserId2 = 'user_provider_2';
    _users[providerUserId2] = {
      'id': providerUserId2,
      'email': 'electric@proxim.ng',
      'password': 'password123',
      'name': 'Ngozi Adebayo',
      'phone': '+2348076543210',
      'role': 'provider',
      'avatarUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final providerId2 = 'provider_2';
    _providers[providerId2] = {
      'id': providerId2,
      'userId': providerUserId2,
      'displayName': 'Ngozi Electrical Services',
      'bio': 'Certified electrician. Wiring, panels, generators, solar install.',
      'categories': ['electrical', 'wiring', 'generator', 'solar'],
      'location': 'Port Harcourt, Rivers',
      'rating': 4.9,
      'reviewCount': 67,
      'completedJobs': 210,
      'isVerified': true,
      'isAvailable': true,
      'hourlyRate': 6000.0,
      'portfolio': [
        {
          'id': 'port_3',
          'title': 'Full house rewiring',
          'description': 'Complete rewire of a 4-bedroom duplex in Rumuokoro.',
          'imageUrl': null,
          'completedAt': '2026-08-20',
        },
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };
    _wallets[providerUserId2] = {
      'userId': providerUserId2,
      'balance': 98000.0,
      'currency': 'NGN',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transactions[providerUserId2] = [];

    // Demo provider 3 – carpenter
    final providerUserId3 = 'user_provider_3';
    _users[providerUserId3] = {
      'id': providerUserId3,
      'email': 'wood@proxim.ng',
      'password': 'password123',
      'name': 'Tunde Bakare',
      'phone': '+2348055512345',
      'role': 'provider',
      'avatarUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final providerId3 = 'provider_3';
    _providers[providerId3] = {
      'id': providerId3,
      'userId': providerUserId3,
      'displayName': 'Tunde Carpentry',
      'bio': 'Custom furniture, doors, cabinets. On-site and workshop.',
      'categories': ['carpentry', 'furniture', 'doors'],
      'location': 'Port Harcourt, Rivers',
      'rating': 4.6,
      'reviewCount': 28,
      'completedJobs': 89,
      'isVerified': true,
      'isAvailable': true,
      'hourlyRate': 4500.0,
      'portfolio': [],
      'createdAt': DateTime.now().toIso8601String(),
    };
    _wallets[providerUserId3] = {
      'userId': providerUserId3,
      'balance': 45000.0,
      'currency': 'NGN',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transactions[providerUserId3] = [];
  }

  // ── Auth ───────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return _users.values.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u!['email'] == email,
          orElse: () => null,
        );
  }

  @override
  Future<Map<String, dynamic>?> getUserById(String id) async {
    return _users[id];
  }

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? 'user_${_uuid.v4()}';
    final user = {
      ...data,
      'id': id,
      'createdAt': DateTime.now().toIso8601String(),
    };
    _users[id] = user;
    _wallets[id] = {
      'userId': id,
      'balance': 0.0,
      'currency': 'NGN',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transactions[id] = [];
    return user;
  }

  @override
  Future<String> createToken(String userId) async {
    final token = 'tok_${_uuid.v4()}';
    _tokens[token] = userId;
    return token;
  }

  @override
  Future<String?> getUserIdByToken(String token) async {
    return _tokens[token];
  }

  @override
  Future<void> revokeToken(String token) async {
    _tokens.remove(token);
  }

  // ── Providers ──────────────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> listProviders({
    String? category,
    String? location,
    String? query,
  }) async {
    var list = _providers.values.toList();
    if (category != null && category.isNotEmpty) {
      list = list
          .where((p) =>
              (p['categories'] as List).any((c) =>
                  c.toString().toLowerCase().contains(category.toLowerCase())))
          .toList();
    }
    if (location != null && location.isNotEmpty) {
      list = list
          .where((p) => (p['location'] as String)
              .toLowerCase()
              .contains(location.toLowerCase()))
          .toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((p) =>
              (p['displayName'] as String).toLowerCase().contains(q) ||
              (p['bio'] as String).toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Future<Map<String, dynamic>?> getProvider(String id) async {
    return _providers[id];
  }

  @override
  Future<Map<String, dynamic>?> getProviderByUserId(String userId) async {
    return _providers.values.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p!['userId'] == userId,
          orElse: () => null,
        );
  }

  @override
  Future<Map<String, dynamic>> createProvider(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? 'provider_${_uuid.v4()}';
    final provider = {
      ...data,
      'id': id,
      'rating': 0.0,
      'reviewCount': 0,
      'completedJobs': 0,
      'isVerified': false,
      'portfolio': data['portfolio'] ?? [],
      'createdAt': DateTime.now().toIso8601String(),
    };
    _providers[id] = provider;
    return provider;
  }

  @override
  Future<Map<String, dynamic>> updateProvider(
      String id, Map<String, dynamic> data) async {
    final existing = _providers[id];
    if (existing == null) throw Exception('Provider not found');
    final updated = {...existing, ...data, 'id': id};
    _providers[id] = updated;
    return updated;
  }

  // ── Jobs ───────────────────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> listJobs({
    String? customerId,
    String? providerId,
    String? status,
  }) async {
    var list = _jobs.values.toList();
    if (customerId != null) {
      list = list.where((j) => j['customerId'] == customerId).toList();
    }
    if (providerId != null) {
      list = list.where((j) => j['providerId'] == providerId).toList();
    }
    if (status != null) {
      list = list.where((j) => j['status'] == status).toList();
    }
    list.sort((a, b) =>
        (b['createdAt'] as String).compareTo(a['createdAt'] as String));
    return list;
  }

  @override
  Future<Map<String, dynamic>?> getJob(String id) async {
    return _jobs[id];
  }

  @override
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? 'job_${_uuid.v4()}';
    final now = DateTime.now().toIso8601String();
    final job = {
      ...data,
      'id': id,
      'status': 'pending',
      'timeline': [
        {
          'status': 'pending',
          'label': 'Request created',
          'at': now,
          'note': null,
        }
      ],
      'createdAt': now,
      'updatedAt': now,
    };
    _jobs[id] = job;
    return job;
  }

  @override
  Future<Map<String, dynamic>> updateJob(
      String id, Map<String, dynamic> data) async {
    final existing = _jobs[id];
    if (existing == null) throw Exception('Job not found');
    final now = DateTime.now().toIso8601String();
    final status = data['status'] as String?;
    final timeline = List<Map<String, dynamic>>.from(existing['timeline'] ?? []);
    if (status != null && status != existing['status']) {
      timeline.add({
        'status': status,
        'label': _statusLabel(status),
        'at': now,
        'note': data['note'],
      });
    }
    final updated = {
      ...existing,
      ...data,
      'id': id,
      'timeline': timeline,
      'updatedAt': now,
    };
    _jobs[id] = updated;
    return updated;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Request created';
      case 'accepted':
        return 'Provider accepted';
      case 'in_progress':
        return 'Work started';
      case 'completed':
        return 'Job completed';
      case 'cancelled':
        return 'Cancelled';
      case 'disputed':
        return 'Disputed';
      default:
        return status;
    }
  }

  // ── Wallet ─────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> getWallet(String userId) async {
    return _wallets[userId];
  }

  @override
  Future<Map<String, dynamic>> updateWallet(
      String userId, Map<String, dynamic> data) async {
    final existing = _wallets[userId] ??
        {
          'userId': userId,
          'balance': 0.0,
          'currency': 'NGN',
        };
    final updated = {
      ...existing,
      ...data,
      'userId': userId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _wallets[userId] = updated;
    return updated;
  }

  @override
  Future<List<Map<String, dynamic>>> listTransactions(String userId) async {
    return List.from(_transactions[userId] ?? []);
  }

  @override
  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? 'txn_${_uuid.v4()}';
    final txn = {
      ...data,
      'id': id,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final userId = data['userId'] as String;
    _transactions.putIfAbsent(userId, () => []);
    _transactions[userId]!.insert(0, txn);
    return txn;
  }

  @override
  Future<void> transfer({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String reference,
    String? note,
  }) async {
    final fromWallet = _wallets[fromUserId];
    final toWallet = _wallets[toUserId];
    if (fromWallet == null || toWallet == null) {
      throw Exception('Wallet not found');
    }
    final fromBal = (fromWallet['balance'] as num).toDouble();
    if (fromBal < amount) throw Exception('Insufficient balance');

    // Deduct + credit
    await updateWallet(fromUserId, {'balance': fromBal - amount});
    final toBal = (toWallet['balance'] as num).toDouble();
    await updateWallet(toUserId, {'balance': toBal + amount});

    // Record both sides
    await createTransaction({
      'userId': fromUserId,
      'type': 'debit',
      'amount': amount,
      'reference': reference,
      'note': note ?? 'Payment for job',
      'counterpartyId': toUserId,
    });
    await createTransaction({
      'userId': toUserId,
      'type': 'credit',
      'amount': amount,
      'reference': reference,
      'note': note ?? 'Payment received',
      'counterpartyId': fromUserId,
    });
  }
}
