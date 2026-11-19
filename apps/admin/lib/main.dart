import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Proxim Admin — lightweight ops dashboard.
void main() {
  runApp(const ProximAdminApp());
}

class ProximAdminApp extends StatelessWidget {
  const ProximAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxim Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F6F3),
      ),
      home: const AdminShell(),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8080',
  );

  int _index = 0;
  bool _loading = true;
  String? _error;
  List<dynamic> _providers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final providersRes = await http.get(Uri.parse('$baseUrl/api/providers'));
      final providersBody = jsonDecode(providersRes.body) as Map<String, dynamic>;
      final providers = providersBody['data'] as List? ?? [];
      setState(() {
        _providers = providers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OverviewPage(
        loading: _loading,
        error: _error,
        providers: _providers,
        onRefresh: _load,
      ),
      _ProvidersPage(providers: _providers, loading: _loading, onRefresh: _load),
      const _SettingsPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.handyman_outlined),
                selectedIcon: Icon(Icons.handyman),
                label: Text('Providers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[_index]),
        ],
      ),
    );
  }
}

class _OverviewPage extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic> providers;
  final Future<void> Function() onRefresh;

  const _OverviewPage({
    required this.loading,
    required this.error,
    required this.providers,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final online = providers.where((p) => p['isOnline'] == true).length;
    final total = providers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxim Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Could not reach API', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      const SizedBox(height: 12),
                      const Text(
                        'Start backend: cd backend && dart run bin/server.dart',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: onRefresh, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      const Text(
                        'Live snapshot from the Proxim API (memory or Firebase).',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _StatCard(label: 'Providers', value: '$total', icon: Icons.handyman),
                          _StatCard(
                            label: 'Online now',
                            value: '$online',
                            icon: Icons.circle,
                            accent: const Color(0xFF22C55E),
                          ),
                          _StatCard(
                            label: 'Offline',
                            value: '${total - online}',
                            icon: Icons.circle_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text('Quick links', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      const Text(
                        '• Mobile: apps/mobile\n'
                        '• API: backend (DATA_SOURCE=memory|firebase)\n'
                        '• Landing: apps/landing/index.html\n'
                        '• Demo customer: ada@proxim.ng / password123\n'
                        '• Demo provider: chinedu@proxim.ng / password123',
                        style: TextStyle(height: 1.6, fontSize: 14),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E2DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: accent ?? const Color(0xFF2E7D32)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProvidersPage extends StatelessWidget {
  final List<dynamic> providers;
  final bool loading;
  final Future<void> Function() onRefresh;

  const _ProvidersPage({
    required this.providers,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Providers')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: providers.isEmpty
                  ? const Center(child: Text('No providers yet'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: providers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = providers[i] as Map<String, dynamic>;
                        final online = p['isOnline'] == true;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE3E2DE)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFE8F5E9),
                                child: Text(
                                  (p['name'] as String? ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(
                                      '${p['category'] ?? ''} · ${p['city'] ?? ''}',
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: online
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  online ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: online ? const Color(0xFF16A34A) : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('Backend', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'Set DATA_SOURCE=memory (default) or DATA_SOURCE=firebase when starting the API.\n'
            'Handlers and repositories stay the same — only the data source implementation swaps.',
            style: TextStyle(height: 1.5, color: Colors.black87),
          ),
          SizedBox(height: 24),
          Text('Admin auth', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'MVP admin is open for local ops. Add admin role + JWT checks before production.',
            style: TextStyle(height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
