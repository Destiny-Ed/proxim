import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/core/di/injector.dart';
import '../lib/features/auth/handler/auth_handler.dart';
import '../lib/features/providers/handler/provider_handler.dart';
import '../lib/features/jobs/handler/job_handler.dart';
import '../lib/features/wallet/handler/wallet_handler.dart';

Future<void> main(List<String> args) async {
  final dataSourceType = Platform.environment['DATA_SOURCE'] ?? 'memory';
  print('🚀 Proxim API starting with DATA_SOURCE=\$dataSourceType');

  setupDependencies(dataSourceType);

  final authHandler = AuthHandler();
  final providerHandler = ProviderHandler();
  final jobHandler = JobHandler();
  final walletHandler = WalletHandler();

  final router = Router()
    ..get('/health', (Request req) => Response.ok('{"status":"ok","service":"proxim"}'))
    ..post('/api/auth/register', authHandler.register)
    ..post('/api/auth/login', authHandler.login)
    ..get('/api/auth/me', authHandler.me)
    ..get('/api/providers', providerHandler.list)
    ..get('/api/providers/<id>', providerHandler.getById)
    ..post('/api/providers/profile', providerHandler.upsertProfile)
    ..patch('/api/providers/online', providerHandler.setOnline)
    ..post('/api/providers/portfolio', providerHandler.addPortfolioItem)
    ..post('/api/jobs', jobHandler.create)
    ..get('/api/jobs', jobHandler.list)
    ..get('/api/jobs/<id>', jobHandler.getById)
    ..patch('/api/jobs/<id>/status', jobHandler.updateStatus)
    ..post('/api/jobs/<id>/rate', jobHandler.rate)
    ..get('/api/wallet', walletHandler.getWallet)
    ..post('/api/wallet/topup', walletHandler.topUp)
    ..get('/api/wallet/transactions', walletHandler.transactions);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(_jsonContentType())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Proxim API listening on http://"${server.address.host}:"${server.port}');
}

Middleware _jsonContentType() {
  return (Handler inner) {
    return (Request request) async {
      final response = await inner(request);
      return response.change(headers: {
        'content-type': 'application/json; charset=utf-8',
        ...response.headers,
      });
    };
  };
}
