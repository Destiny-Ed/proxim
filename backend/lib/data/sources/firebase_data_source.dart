import 'data_source.dart';

/// Firebase stubs — implement these methods when ready to switch.
/// Set DATA_SOURCE=firebase and restart the server.
/// Handlers / repositories stay untouched.

class FirebaseAuthDataSource implements AuthDataSource {
  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) {
    throw UnimplementedError('FirebaseAuthDataSource.register — implement with Firebase Auth + Firestore');
  }

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) {
    throw UnimplementedError('FirebaseAuthDataSource.login');
  }

  @override
  Future<Map<String, dynamic>?> getUserById(String id) {
    throw UnimplementedError('FirebaseAuthDataSource.getUserById');
  }

  @override
  Future<Map<String, dynamic>?> getUserByToken(String token) {
    throw UnimplementedError('FirebaseAuthDataSource.getUserByToken');
  }
}

class FirebaseProviderDataSource implements ProviderDataSource {
  @override
  Future<List<Map<String, dynamic>>> list({String? category, String? city, bool? onlineOnly}) {
    throw UnimplementedError('FirebaseProviderDataSource.list');
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) {
    throw UnimplementedError('FirebaseProviderDataSource.getById');
  }

  @override
  Future<Map<String, dynamic>> upsertProfile(String userId, Map<String, dynamic> data) {
    throw UnimplementedError('FirebaseProviderDataSource.upsertProfile');
  }

  @override
  Future<Map<String, dynamic>> setOnline(String userId, bool isOnline) {
    throw UnimplementedError('FirebaseProviderDataSource.setOnline');
  }

  @override
  Future<Map<String, dynamic>> addPortfolioItem(String userId, Map<String, dynamic> item) {
    throw UnimplementedError('FirebaseProviderDataSource.addPortfolioItem');
  }
}

class FirebaseJobDataSource implements JobDataSource {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) {
    throw UnimplementedError('FirebaseJobDataSource.create');
  }

  @override
  Future<List<Map<String, dynamic>>> list({String? customerId, String? providerId, String? status}) {
    throw UnimplementedError('FirebaseJobDataSource.list');
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) {
    throw UnimplementedError('FirebaseJobDataSource.getById');
  }

  @override
  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? note}) {
    throw UnimplementedError('FirebaseJobDataSource.updateStatus');
  }

  @override
  Future<Map<String, dynamic>> rate(String id, int rating, String? review) {
    throw UnimplementedError('FirebaseJobDataSource.rate');
  }
}

class FirebaseWalletDataSource implements WalletDataSource {
  @override
  Future<Map<String, dynamic>> getWallet(String userId) {
    throw UnimplementedError('FirebaseWalletDataSource.getWallet');
  }

  @override
  Future<Map<String, dynamic>> topUp(String userId, double amount, {String? reference}) {
    throw UnimplementedError('FirebaseWalletDataSource.topUp');
  }

  @override
  Future<Map<String, dynamic>> debit(String userId, double amount, {String? reason, String? jobId}) {
    throw UnimplementedError('FirebaseWalletDataSource.debit');
  }

  @override
  Future<Map<String, dynamic>> credit(String userId, double amount, {String? reason, String? jobId}) {
    throw UnimplementedError('FirebaseWalletDataSource.credit');
  }

  @override
  Future<List<Map<String, dynamic>>> transactions(String userId) {
    throw UnimplementedError('FirebaseWalletDataSource.transactions');
  }
}
