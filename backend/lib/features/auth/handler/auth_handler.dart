import 'package:shelf/shelf.dart';
import '../../../core/di/injector.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/response_helper.dart';

class AuthHandler {
  Future<Response> register(Request request) async {
    try {
      final body = await readJson(request);
      final name = body['name']?.toString().trim();
      final email = body['email']?.toString().trim().toLowerCase();
      final phone = body['phone']?.toString().trim();
      final password = body['password']?.toString();
      final role = body['role']?.toString().toLowerCase() ?? 'customer';

      if (name == null || name.isEmpty)
        throw ValidationException('Name is required');
      if (email == null || email.isEmpty || !email.contains('@')) {
        throw ValidationException('Valid email is required');
      }
      if (phone == null || phone.isEmpty)
        throw ValidationException('Phone is required');
      if (password == null || password.length < 6) {
        throw ValidationException('Password must be at least 6 characters');
      }
      if (role != 'customer' && role != 'provider') {
        throw ValidationException('Role must be customer or provider');
      }

      final user = await Injector.authRepo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      return ok(user, status: 201);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> login(Request request) async {
    try {
      final body = await readJson(request);
      final email = body['email']?.toString().trim().toLowerCase();
      final password = body['password']?.toString();
      if (email == null || password == null) {
        throw ValidationException('Email and password are required');
      }
      final user =
          await Injector.authRepo.login(email: email, password: password);
      return ok(user);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> me(Request request) async {
    try {
      final token = getBearerToken(request);
      if (token == null) throw UnauthorizedException();
      final user = await Injector.authRepo.me(token);
      if (user == null) throw UnauthorizedException('Invalid or expired token');
      return ok(user);
    } catch (e) {
      return fail(e);
    }
  }
}
