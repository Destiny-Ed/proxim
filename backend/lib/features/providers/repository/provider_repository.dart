abstract class ProviderRepository {
  Future<List<Map<String, dynamic>>> list({String? category, String? city, bool? onlineOnly});
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>> upsertProfile(String userId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> setOnline(String userId, bool isOnline);
  Future<Map<String, dynamic>> addPortfolioItem(String userId, Map<String, dynamic> item);
}
