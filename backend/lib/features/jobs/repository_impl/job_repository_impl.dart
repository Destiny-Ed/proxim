import '../../../data/sources/data_source.dart';
import '../repository/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobDataSource _ds;
  JobRepositoryImpl(this._ds);

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) => _ds.create(data);

  @override
  Future<List<Map<String, dynamic>>> list({String? customerId, String? providerId, String? status}) =>
      _ds.list(customerId: customerId, providerId: providerId, status: status);

  @override
  Future<Map<String, dynamic>?> getById(String id) => _ds.getById(id);

  @override
  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? note}) =>
      _ds.updateStatus(id, status, note: note);

  @override
  Future<Map<String, dynamic>> rate(String id, int rating, String? review) =>
      _ds.rate(id, rating, review);
}
