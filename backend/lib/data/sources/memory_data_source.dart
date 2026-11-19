import 'package:uuid/uuid.dart';
import 'data_source.dart';

final _uuid = Uuid();

// ─────────────────────────────────────────────
// In-memory store (shared across features)
// ─────────────────────────────────────────────
class _Store {
  static final users = <String, Map<String, dynamic>>{};
  static final tokens = <String, String>{}; // token → userId
  static final providers = <String, Map<String, dynamic>>{};
  static final jobs = <String, Map<String, dynamic>>{};
  static final wallets = <String, Map<String, dynamic>>{};
  static final transactions = <String, List<Map<String, dynamic>>>{};

  static void seed() {
    if (users.isNotEmpty) return;

    // Demo customer
    final custId = 'cust_demo';
    users[custId] = {
      'id': custId,
      'name': 'Ada Okoro',
      'email': 'ada@proxim.ng',
      'phone': '+2348011111111',
      'password': 'password123',
      'role': 'customer',
      'avatarUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    wallets[custId] = {'userId': custId, 'balance': 25000.0, 'currency': 'NGN'};
    transactions[custId] = [];

    // Demo providers
    final providersSeed = [
      {
        'id': 'prov_1',
        'name': 'Chinedu Plumbing',
        'email': 'chinedu@proxim.ng',
        'phone': '+2348022222222',
        'category': 'Plumbing',
        'bio': '10+ years fixing leaks, installing water heaters & bathrooms across Port Harcourt.',
        'city': 'Port Harcourt',
        'area': 'Rumuokoro',
        'hourlyRate': 5000.0,
        'rating': 4.9,
        'reviewCount': 128,
        'jobsCompleted': 340,
        'isOnline': true,
        'services': ['Leak repair', 'Pipe installation', 'Water heater', 'Bathroom fitting'],
        'portfolio': [
          {'id': 'p1', 'title': 'Full bathroom remodel', 'imageUrl': null, 'description': 'Complete piping + fixtures'},
          {'id': 'p2', 'title': 'Kitchen sink install', 'imageUrl': null, 'description': 'Modern sink + filter'},
        ],
      },
      {
        'id': 'prov_2',
        'name': 'Amaka Styles',
        'email': 'amaka@proxim.ng',
        'phone': '+2348033333333',
        'category': 'Beauty & Hair',
        'bio': 'Professional stylist. Braids, weave, makeup & bridal looks.',
        'city': 'Port Harcourt',
        'area': 'GRA',
        'hourlyRate': 8000.0,
        'rating': 4.8,
        'reviewCount': 95,
        'jobsCompleted': 210,
        'isOnline': true,
        'services': ['Braids', 'Weave installation', 'Makeup', 'Bridal'],
        'portfolio': [
          {'id': 'p3', 'title': 'Bridal glam', 'imageUrl': null, 'description': 'Full bridal package'},
        ],
      },
      {
        'id': 'prov_3',
        'name': 'Spark Electric',
        'email': 'spark@proxim.ng',
        'phone': '+2348044444444',
        'category': 'Electrical',
        'bio': 'Licensed electrician. Wiring, generators, solar & smart home.',
        'city': 'Port Harcourt',
        'area': 'Trans-Amadi',
        'hourlyRate': 6000.0,
        'rating': 4.7,
        'reviewCount': 76,
        'jobsCompleted': 185,
        'isOnline': false,
        'services': ['House wiring', 'Generator install', 'Solar setup', 'Fault diagnosis'],
        'portfolio': [],
      },
      {
        'id': 'prov_4',
        'name': 'CleanForce PH',
        'email': 'clean@proxim.ng',
        'phone': '+2348055555555',
        'category': 'Cleaning',
        'bio': 'Home & office deep cleaning. Eco-friendly products.',
        'city': 'Port Harcourt',
        'area': 'Abuloma',
        'hourlyRate': 3500.0,
        'rating': 4.6,
        'reviewCount': 54,
        'jobsCompleted': 120,
        'isOnline': true,
        'services': ['Deep cleaning', 'Office cleaning', 'Post-construction', 'Sofa cleaning'],
        'portfolio': [],
      },
      {
        'id': 'prov_5',
        'name': 'Shine Auto',
        'email': 'shine@proxim.ng',
        'phone': '+2348066666666',
        'category': 'Car Wash',
        'bio': 'Mobile car wash & detailing. We come to you.',
        'city': 'Port Harcourt',
        'area': 'Rumuola',
        'hourlyRate': 4000.0,
        'rating': 4.85,
        'reviewCount': 210,
        'jobsCompleted': 480,
        'isOnline': true,
        'services': ['Exterior wash', 'Interior detailing', 'Engine wash', 'Ceramic coating'],
        'portfolio': [],
      },
    ];

    for (final p in providersSeed) {
      final id = p['id'] as String;
      users[id] = {
        'id': id,
        'name': p['name'],
        'email': p['email'],
        'phone': p['phone'],
        'password': 'password123',
        'role': 'provider',
        'avatarUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      };
      providers[id] = {
        ...p,
        'userId': id,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      wallets[id] = {'userId': id, 'balance': 125000.0, 'currency': 'NGN'};
      transactions[id] = [];
    }
  }
}

// ─────────────────────────────────────────────
// Auth
// ─────────────────────────────────────────────
class MemoryAuthDataSource implements AuthDataSource {
  MemoryAuthDataSource() {
    _Store.seed();
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    if (_Store.users.values.any((u) => u['email'] == email)) {
      throw Exception('Email already registered');
    }
    final id = _uuid.v4();
    final user = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'avatarUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    _Store.users[id] = user;
    _Store.wallets[id] = {'userId': id, 'balance': 0.0, 'currency': 'NGN'};
    _Store.transactions[id] = [];

    if (role == 'provider') {
      _Store.providers[id] = {
        'id': id,
        'userId': id,
        'name': name,
        'email': email,
        'phone': phone,
        'category': '',
        'bio': '',
        'city': 'Port Harcourt',
        'area': '',
        'hourlyRate': 0.0,
        'rating': 0.0,
        'reviewCount': 0,
        'jobsCompleted': 0,
        'isOnline': false,
        'services': <String>[],
        'portfolio': <Map<String, dynamic>>[],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }

    final token = _uuid.v4();
    _Store.tokens[token] = id;
    return _safeUser(user)..['token'] = token;
  }

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final user = _Store.users.values.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u!['email'] == email && u['password'] == password,
          orElse: () => null,
        );
    if (user == null) throw Exception('Invalid email or password');
    final token = _uuid.v4();
    _Store.tokens[token] = user['id'];
    return _safeUser(user)..['token'] = token;
  }

  @override
  Future<Map<String, dynamic>?> getUserById(String id) async {
    final u = _Store.users[id];
    return u == null ? null : _safeUser(u);
  }

  @override
  Future<Map<String, dynamic>?> getUserByToken(String token) async {
    final id = _Store.tokens[token];
    if (id == null) return null;
    return getUserById(id);
  }

  Map<String, dynamic> _safeUser(Map<String, dynamic> u) {
    final copy = Map<String, dynamic>.from(u);
    copy.remove('password');
    return copy;
  }
}

// ─────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────
class MemoryProviderDataSource implements ProviderDataSource {
  MemoryProviderDataSource() {
    _Store.seed();
  }

  @override
  Future<List<Map<String, dynamic>>> list({
    String? category,
    String? city,
    bool? onlineOnly,
  }) async {
    var list = _Store.providers.values.toList();
    if (category != null && category.isNotEmpty) {
      list = list.where((p) => (p['category'] as String).toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (city != null && city.isNotEmpty) {
      list = list.where((p) => (p['city'] as String).toLowerCase().contains(city.toLowerCase())).toList();
    }
    if (onlineOnly == true) {
      list = list.where((p) => p['isOnline'] == true).toList();
    }
    list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    return list;
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) async => _Store.providers[id];

  @override
  Future<Map<String, dynamic>> upsertProfile(String userId, Map<String, dynamic> data) async {
    final existing = _Store.providers[userId] ?? {
      'id': userId,
      'userId': userId,
      'services': <String>[],
      'portfolio': <Map<String, dynamic>>[],
      'rating': 0.0,
      'reviewCount': 0,
      'jobsCompleted': 0,
      'isOnline': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final updated = {
      ...existing,
      ...data,
      'id': userId,
      'userId': userId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _Store.providers[userId] = updated;
    if (data['name'] != null && _Store.users[userId] != null) {
      _Store.users[userId]!['name'] = data['name'];
    }
    return updated;
  }

  @override
  Future<Map<String, dynamic>> setOnline(String userId, bool isOnline) async {
    final p = _Store.providers[userId];
    if (p == null) throw Exception('Provider profile not found');
    p['isOnline'] = isOnline;
    p['updatedAt'] = DateTime.now().toIso8601String();
    return p;
  }

  @override
  Future<Map<String, dynamic>> addPortfolioItem(String userId, Map<String, dynamic> item) async {
    final p = _Store.providers[userId];
    if (p == null) throw Exception('Provider profile not found');
    final list = List<Map<String, dynamic>>.from(p['portfolio'] ?? []);
    final newItem = {
      'id': _uuid.v4(),
      ...item,
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.add(newItem);
    p['portfolio'] = list;
    p['updatedAt'] = DateTime.now().toIso8601String();
    return p;
  }
}

// ─────────────────────────────────────────────
// Jobs
// ─────────────────────────────────────────────
class MemoryJobDataSource implements JobDataSource {
  MemoryJobDataSource() {
    _Store.seed();
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    final job = {
      'id': id,
      ...data,
      'status': 'pending',
      'timeline': [
        {
          'status': 'pending',
          'note': 'Request created',
          'at': DateTime.now().toIso8601String(),
        }
      ],
      'rating': null,
      'review': null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _Store.jobs[id] = job;
    return job;
  }

  @override
  Future<List<Map<String, dynamic>>> list({
    String? customerId,
    String? providerId,
    String? status,
  }) async {
    var list = _Store.jobs.values.toList();
    if (customerId != null) list = list.where((j) => j['customerId'] == customerId).toList();
    if (providerId != null) list = list.where((j) => j['providerId'] == providerId).toList();
    if (status != null) list = list.where((j) => j['status'] == status).toList();
    list.sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
    return list;
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) async => _Store.jobs[id];

  @override
  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? note}) async {
    final job = _Store.jobs[id];
    if (job == null) throw Exception('Job not found');
    job['status'] = status;
    job['updatedAt'] = DateTime.now().toIso8601String();
    final timeline = List<Map<String, dynamic>>.from(job['timeline'] ?? []);
    timeline.add({
      'status': status,
      'note': note ?? status,
      'at': DateTime.now().toIso8601String(),
    });
    job['timeline'] = timeline;

    // On completed → credit provider (85% payout, 15% platform)
    if (status == 'completed') {
      final providerId = job['providerId'] as String?;
      final amount = (job['budget'] as num?)?.toDouble() ?? 0.0;
      if (providerId != null && amount > 0) {
        final payout = amount * 0.85;
        final wallet = _Store.wallets[providerId] ?? {'userId': providerId, 'balance': 0.0, 'currency': 'NGN'};
        wallet['balance'] = (wallet['balance'] as num) + payout;
        _Store.wallets[providerId] = wallet;
        final txs = _Store.transactions[providerId] ?? [];
        txs.insert(0, {
          'id': _uuid.v4(),
          'type': 'credit',
          'amount': payout,
          'reason': 'Job payout',
          'jobId': id,
          'at': DateTime.now().toIso8601String(),
        });
        _Store.transactions[providerId] = txs;

        final prov = _Store.providers[providerId];
        if (prov != null) {
          prov['jobsCompleted'] = (prov['jobsCompleted'] as int? ?? 0) + 1;
        }
      }
    }
    return job;
  }

  @override
  Future<Map<String, dynamic>> rate(String id, int rating, String? review) async {
    final job = _Store.jobs[id];
    if (job == null) throw Exception('Job not found');
    if (job['status'] != 'completed') throw Exception('Can only rate completed jobs');
    job['rating'] = rating;
    job['review'] = review;
    job['updatedAt'] = DateTime.now().toIso8601String();

    final providerId = job['providerId'] as String?;
    if (providerId != null) {
      final prov = _Store.providers[providerId];
      if (prov != null) {
        final count = (prov['reviewCount'] as int? ?? 0) + 1;
        final old = (prov['rating'] as num?)?.toDouble() ?? 0.0;
        prov['rating'] = ((old * (count - 1)) + rating) / count;
        prov['reviewCount'] = count;
      }
    }
    return job;
  }
}

// ─────────────────────────────────────────────
// Wallet
// ─────────────────────────────────────────────
class MemoryWalletDataSource implements WalletDataSource {
  MemoryWalletDataSource() {
    _Store.seed();
  }

  @override
  Future<Map<String, dynamic>> getWallet(String userId) async {
    return _Store.wallets[userId] ?? {'userId': userId, 'balance': 0.0, 'currency': 'NGN'};
  }

  @override
  Future<Map<String, dynamic>> topUp(String userId, double amount, {String? reference}) async {
    final wallet = await getWallet(userId);
    wallet['balance'] = (wallet['balance'] as num) + amount;
    _Store.wallets[userId] = wallet;
    final txs = _Store.transactions[userId] ?? [];
    txs.insert(0, {
      'id': _uuid.v4(),
      'type': 'credit',
      'amount': amount,
      'reason': 'Wallet top-up',
      'reference': reference,
      'at': DateTime.now().toIso8601String(),
    });
    _Store.transactions[userId] = txs;
    return wallet;
  }

  @override
  Future<Map<String, dynamic>> debit(String userId, double amount, {String? reason, String? jobId}) async {
    final wallet = await getWallet(userId);
    final bal = (wallet['balance'] as num).toDouble();
    if (bal < amount) throw Exception('Insufficient balance');
    wallet['balance'] = bal - amount;
    _Store.wallets[userId] = wallet;
    final txs = _Store.transactions[userId] ?? [];
    txs.insert(0, {
      'id': _uuid.v4(),
      'type': 'debit',
      'amount': amount,
      'reason': reason ?? 'Debit',
      'jobId': jobId,
      'at': DateTime.now().toIso8601String(),
    });
    _Store.transactions[userId] = txs;
    return wallet;
  }

  @override
  Future<Map<String, dynamic>> credit(String userId, double amount, {String? reason, String? jobId}) async {
    final wallet = await getWallet(userId);
    wallet['balance'] = (wallet['balance'] as num) + amount;
    _Store.wallets[userId] = wallet;
    final txs = _Store.transactions[userId] ?? [];
    txs.insert(0, {
      'id': _uuid.v4(),
      'type': 'credit',
      'amount': amount,
      'reason': reason ?? 'Credit',
      'jobId': jobId,
      'at': DateTime.now().toIso8601String(),
    });
    _Store.transactions[userId] = txs;
    return wallet;
  }

  @override
  Future<List<Map<String, dynamic>>> transactions(String userId) async {
    return List.from(_Store.transactions[userId] ?? []);
  }
}
