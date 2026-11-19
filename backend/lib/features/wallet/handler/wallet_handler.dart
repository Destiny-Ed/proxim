import 'package:shelf/shelf.dart';
import '../../../core/di/injector.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/response_helper.dart';

class WalletHandler {
  Future<Map<String, dynamic>> _requireUser(Request request) async {
    final token = getBearerToken(request);
    if (token == null) throw UnauthorizedException();
    final user = await Injector.authRepo.me(token);
    if (user == null) throw UnauthorizedException();
    return user;
  }

  Future<Response> getWallet(Request request) async {
    try {
      final user = await _requireUser(request);
      final wallet = await Injector.walletRepo.getWallet(user['id']);
      return ok(wallet);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> topUp(Request request) async {
    try {
      final user = await _requireUser(request);
      final body = await readJson(request);
      final amount = (body['amount'] as num?)?.toDouble();
      final reference = body['reference']?.toString();
      if (amount == null || amount <= 0) throw ValidationException('Valid amount is required');
      final wallet = await Injector.walletRepo.topUp(user['id'], amount, reference: reference);
      return ok(wallet);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> transactions(Request request) async {
    try {
      final user = await _requireUser(request);
      final txs = await Injector.walletRepo.transactions(user['id']);
      return ok(txs);
    } catch (e) {
      return fail(e);
    }
  }
}
