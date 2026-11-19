import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/utils/response_helper.dart';
import '../repository/job_repository.dart';

class JobHandler {
  final JobRepository _repo;

  JobHandler(this._repo);

  Router get router {
    final r = Router();

    r.get('/', _list);
    r.get('/<id>', _get);
    r.post('/', _create);
    r.patch('/<id>', _update);
    r.post('/<id>/accept', _accept);
    r.post('/<id>/start', _start);
    r.post('/<id>/complete', _complete);
    r.post('/<id>/cancel', _cancel);

    return r;
  }

  Future<Response> _list(Request request) async {
    try {
      final customerId = request.url.queryParameters['customerId'];
      final providerId = request.url.queryParameters['providerId'];
      final status = request.url.queryParameters['status'];
      final jobs = await _repo.list(
        customerId: customerId,
        providerId: providerId,
        status: status,
      );
      return ok(jobs);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _get(Request request, String id) async {
    try {
      final job = await _repo.getById(id);
      if (job == null) return notFound('Job not found');
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final required = ['customerId', 'title', 'description', 'category'];
      for (final k in required) {
        if (body[k] == null || (body[k] is String && (body[k] as String).isEmpty)) {
          return badRequest('Missing required field: $k');
        }
      }
      final job = await _repo.create(body);
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _update(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final job = await _repo.update(id, body);
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _accept(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final providerId = body['providerId'] as String?;
      if (providerId == null) return badRequest('providerId required');
      final job = await _repo.update(id, {
        'status': 'accepted',
        'providerId': providerId,
        'note': body['note'],
      });
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _start(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>? ?? {};
      final job = await _repo.update(id, {
        'status': 'in_progress',
        'note': body['note'],
      });
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _complete(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>? ?? {};
      final job = await _repo.update(id, {
        'status': 'completed',
        'note': body['note'],
        'completedAt': DateTime.now().toIso8601String(),
      });
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }

  Future<Response> _cancel(Request request, String id) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>? ?? {};
      final job = await _repo.update(id, {
        'status': 'cancelled',
        'note': body['note'],
      });
      return ok(job);
    } catch (e) {
      return fail(e.toString());
    }
  }
}
