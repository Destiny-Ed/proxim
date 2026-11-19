import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../error/app_exception.dart';

Response ok(Object data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode({'success': true, 'data': data}),
    headers: {'content-type': 'application/json'},
  );
}

Response fail(Object error, {int status = 400}) {
  String message = error.toString();
  String? code;
  if (error is AppException) {
    message = error.message;
    code = error.code;
    status = error.statusCode;
  }
  return Response(
    status,
    body: jsonEncode({
      'success': false,
      'error': {'message': message, if (code != null) 'code': code},
    }),
    headers: {'content-type': 'application/json'},
  );
}

/// Convenience helpers (optional — prefer throwing AppException + fail())
Response notFound(String message) => fail(NotFoundException(message));
Response badRequest(String message) => fail(ValidationException(message));

Future<Map<String, dynamic>> readJson(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  return jsonDecode(body) as Map<String, dynamic>;
}

String? getBearerToken(Request request) {
  final auth = request.headers['authorization'];
  if (auth == null || !auth.startsWith('Bearer ')) return null;
  return auth.substring(7).trim();
}
