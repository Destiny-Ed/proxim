/// Abstract DataSource interface.
/// Swap implementations (Memory → Firebase → Postgres) without touching
/// handlers, repositories, or repository_impls.
abstract class AuthDataSource {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, // customer | provider
  });
  Future<Map<String, dynamic>> login({required String email, required String password});
  Future<Map<String, dynamic>?> getUserById(String id);
  Future<Map<String, dynamic>?> getUserByToken(String token);
}

abstract class ProviderDataSource {
  Future<List<Map<String, dynamic>>> list({
    String? category,
    String? city,
    bool? onlineOnly,
  });
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>> upsertProfile(String userId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> setOnline(String userId, bool isOnline);
  Future<Map<String, dynamic>> addPortfolioItem(String userId, Map<String, dynamic> item);
}

abstract class JobDataSource {
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> list({
    String? customerId,
    String? providerId,
    String? status,
  });
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? note});
  Future<Map<String, dynamic>> rate(String id, int rating, String? review);
}

abstract class WalletDataSource {
  Future<Map<String, dynamic>> getWallet(String userId);
  Future<Map<String, dynamic>> topUp(String userId, double amount, {String? reference});
  Future<Map<String, dynamic>> debit(String userId, double amount, {String? reason, String? jobId});
  Future<Map<String, dynamic>> credit(String userId, double amount, {String? reason, String? jobId});
  Future<List<Map<String, dynamic>>> transactions(String userId);
}
