import 'package:shelf/shelf.dart';
import '../../../core/di/injector.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/response_helper.dart';

class JobHandler {
  Future<Map<String, dynamic>> _requireUser(Request request) async {
    final token = getBearerToken(request);
    if (token == null) throw UnauthorizedException();
    final user = await Injector.authRepo.me(token);
    if (user == null) throw UnauthorizedException();
    return user;
  }

  Future<Response> create(Request request) async {
    try {
      final user = await _requireUser(request);
      if (user['role'] != 'customer') throw ValidationException('Only customers can create job requests');

      final body = await readJson(request);
      final providerId = body['providerId']?.toString();
      final title = body['title']?.toString().trim();
      final description = body['description']?.toString().trim();
      final budget = (body['budget'] as num?)?.toDouble();
      final address = body['address']?.toString().trim();
      final preferredTime = body['preferredTime']?.toString();

      if (providerId == null || providerId.isEmpty) throw ValidationException('providerId is required');
      if (title == null || title.isEmpty) throw ValidationException('Title is required');
      if (description == null || description.isEmpty) throw ValidationException('Description is required');
      if (budget == null || budget <= 0) throw ValidationException('Valid budget is required');

      final provider = await Injector.providerRepo.getById(providerId);
      if (provider == null) throw NotFoundException('Provider not found');

      final job = await Injector.jobRepo.create({
        'customerId': user['id'],
        'customerName': user['name'],
        'providerId': providerId,
        'providerName': provider['name'],
        'title': title,
        'description': description,
        'budget': budget,
        'address': address ?? '',
        'preferredTime': preferredTime,
        'category': provider['category'],
      });
      return ok(job, status: 201);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> list(Request request) async {
    try {
      final user = await _requireUser(request);
      final status = request.url.queryParameters['status'];
      List<Map<String, dynamic>> jobs;
      if (user['role'] == 'provider') {
        jobs = await Injector.jobRepo.list(providerId: user['id'], status: status);
      } else {
        jobs = await Injector.jobRepo.list(customerId: user['id'], status: status);
      }
      return ok(jobs);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> getById(Request request, String id) async {
    try {
      final user = await _requireUser(request);
      final job = await Injector.jobRepo.getById(id);
      if (job == null) throw NotFoundException('Job not found');
      // simple ownership check
      if (job['customerId'] != user['id'] && job['providerId'] != user['id']) {
        throw UnauthorizedException('Not your job');
      }
      return ok(job);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> updateStatus(Request request, String id) async {
    try {
      final user = await _requireUser(request);
      final body = await readJson(request);
      final status = body['status']?.toString().toLowerCase();
      final note = body['note']?.toString();

      if (status == null) throw ValidationException('status is required');
      final allowed = ['accepted', 'rejected', 'in_progress', 'completed', 'cancelled'];
      if (!allowed.contains(status)) throw ValidationException('Invalid status');

      final job = await Injector.jobRepo.getById(id);
      if (job == null) throw NotFoundException('Job not found');

      // Providers can accept/reject/in_progress/completed
      // Customers can cancel (if still pending)
      if (user['role'] == 'provider' && job['providerId'] == user['id']) {
        if (!['accepted', 'rejected', 'in_progress', 'completed'].contains(status)) {
          throw ValidationException('Providers cannot set status to $status');
        }
      } else if (user['role'] == 'customer' && job['customerId'] == user['id']) {
        if (status != 'cancelled') throw ValidationException('Customers can only cancel');
        if (job['status'] != 'pending') throw ValidationException('Can only cancel pending requests');
      } else {
        throw UnauthorizedException();
      }

      final updated = await Injector.jobRepo.updateStatus(id, status, note: note);
      return ok(updated);
    } catch (e) {
      return fail(e);
    }
  }

  Future<Response> rate(Request request, String id) async {
    try {
      final user = await _requireUser(request);
      if (user['role'] != 'customer') throw ValidationException('Only customers can rate');
      final body = await readJson(request);
      final rating = body['rating'] as int?;
      final review = body['review']?.toString();
      if (rating == null || rating < 1 || rating > 5) {
        throw ValidationException('Rating must be 1–5');
      }
      final job = await Injector.jobRepo.getById(id);
      if (job == null) throw NotFoundException('Job not found');
      if (job['customerId'] != user['id']) throw UnauthorizedException();
      final updated = await Injector.jobRepo.rate(id, rating, review);
      return ok(updated);
    } catch (e) {
      return fail(e);
    }
  }
}
