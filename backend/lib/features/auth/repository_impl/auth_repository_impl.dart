import '../../../data/sources/data_source.dart';
import '../repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) =>
      _ds.register(name: name, email: email, phone: phone, password: password, role: role);

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) =>
      _ds.login(email: email, password: password);

  @override
  Future<Map<String, dynamic>?> me(String token) => _ds.getUserByToken(token);
}
