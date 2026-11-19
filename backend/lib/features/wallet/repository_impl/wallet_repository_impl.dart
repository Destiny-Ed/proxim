import '../../../data/sources/data_source.dart';
import '../repository/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource _ds;
  WalletRepositoryImpl(this._ds);

  @override
  Future<Map<String, dynamic>> getWallet(String userId) => _ds.getWallet(userId);

  @override
  Future<Map<String, dynamic>> topUp(String userId, double amount, {String? reference}) =>
      _ds.topUp(userId, amount, reference: reference);

  @override
  Future<List<Map<String, dynamic>>> transactions(String userId) => _ds.transactions(userId);
}
