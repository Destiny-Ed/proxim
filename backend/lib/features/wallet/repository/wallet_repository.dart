abstract class WalletRepository {
  Future<Map<String, dynamic>> getWallet(String userId);
  Future<Map<String, dynamic>> topUp(String userId, double amount, {String? reference});
  Future<List<Map<String, dynamic>>> transactions(String userId);
}
