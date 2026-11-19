import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/customer_shell.dart';
import 'features/home/screens/provider_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProximApp());
}

class ProximApp extends StatelessWidget {
  const ProximApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'Proxim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.isLoggedIn) return const LoginScreen();
    if (state.isProvider) return const ProviderShell();
    return const CustomerShell();
  }
}
