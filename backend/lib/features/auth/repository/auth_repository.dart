abstract class AuthRepository {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  });
  Future<Map<String, dynamic>> login({required String email, required String password});
  Future<Map<String, dynamic>?> me(String token);
}
