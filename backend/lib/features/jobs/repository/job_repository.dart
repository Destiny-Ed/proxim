abstract class JobRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> list({String? customerId, String? providerId, String? status});
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? note});
  Future<Map<String, dynamic>> rate(String id, int rating, String? review);
}
