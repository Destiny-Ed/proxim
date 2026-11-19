import '../../../data/sources/data_source.dart';
import '../repository/provider_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderDataSource _ds;
  ProviderRepositoryImpl(this._ds);

  @override
  Future<List<Map<String, dynamic>>> list({String? category, String? city, bool? onlineOnly}) =>
      _ds.list(category: category, city: city, onlineOnly: onlineOnly);

  @override
  Future<Map<String, dynamic>?> getById(String id) => _ds.getById(id);

  @override
  Future<Map<String, dynamic>> upsertProfile(String userId, Map<String, dynamic> data) =>
      _ds.upsertProfile(userId, data);

  @override
  Future<Map<String, dynamic>> setOnline(String userId, bool isOnline) =>
      _ds.setOnline(userId, isOnline);

  @override
  Future<Map<String, dynamic>> addPortfolioItem(String userId, Map<String, dynamic> item) =>
      _ds.addPortfolioItem(userId, item);
}
