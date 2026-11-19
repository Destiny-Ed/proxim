import 'package:shelf/shelf.dart';
import '../../../core/di/injector.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/response_helper.dart';

class ProviderHandler {
  Future<Map<String, dynamic>> _requireUser(Request request) async {
    final token = getBearerToken(request);
    if (token == null) throw UnauthorizedException();
    final user = await Injector.authRepo.me(token);
    if (user == null) throw UnauthorizedException();
    return user;
  }

  Future<Response> list(Request request) async {
    try {
      final params = request.url.queryParameters;
      final list = await Injector.providerRepo.list(
        category: params['category'],
        city: params['city'],
        onlineOnly: params['online'] == 'true',
      );
      return ok(list);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> getById(Request request, String id) async {
    try {
      final p = await Injector.providerRepo.getById(id);
      if (p == null) throw NotFoundException('Provider not found');
      return ok(p);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> upsertProfile(Request request) async {
    try {
      final user = await _requireUser(request);
      if (user['role'] != 'provider') throw ValidationException('Only providers can update profile');
      final body = await readJson(request);
      final updated = await Injector.providerRepo.upsertProfile(user['id'], body);
      return ok(updated);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> setOnline(Request request) async {
    try {
      final user = await _requireUser(request);
      if (user['role'] != 'provider') throw ValidationException('Only providers can go online');
      final body = await readJson(request);
      final isOnline = body['isOnline'] == true;
      final updated = await Injector.providerRepo.setOnline(user['id'], isOnline);
      return ok(updated);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> addPortfolioItem(Request request) async {
    try {
      final user = await _requireUser(request);
      if (user['role'] != 'provider') throw ValidationException('Only providers can add portfolio');
      final body = await readJson(request);
      if (body['title'] == null) throw ValidationException('Title is required');
      final updated = await Injector.providerRepo.addPortfolioItem(user['id'], body);
      return ok(updated);
    } catch (e) {
      return fail(e);
    }
  }
}
