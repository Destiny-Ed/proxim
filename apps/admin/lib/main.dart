import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Proxim Admin — ops dashboard against the Shelf API.
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F6F3),
          elevation: 0,
          foregroundColor: Color(0xFF1F1F1F),
        ),
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
  String? _health;
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
      final healthRes = await http.get(Uri.parse('$baseUrl/health'));
      final healthBody = healthRes.body;

      final providersRes = await http.get(Uri.parse('$baseUrl/api/providers'));
      final providersBody =
          jsonDecode(providersRes.body) as Map<String, dynamic>;
      final providers = providersBody['data'] as List? ?? [];

      setState(() {
        _health = healthBody;
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
        health: _health,
        providers: _providers,
        onRefresh: _load,
      ),
      _ProvidersPage(
        providers: _providers,
        loading: _loading,
        onRefresh: _load,
      ),
      _SettingsPage(baseUrl: baseUrl, health: _health),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
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
  final String? health;
  final List<dynamic> providers;
  final Future<void> Function() onRefresh;

  const _OverviewPage({
    required this.loading,
    required this.error,
    required this.health,
    required this.providers,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final online = providers.where((p) => p['isOnline'] == true).length;
    final total = providers.length;
    final categories = <String, int>{};
    for (final p in providers) {
      final c = (p['category'] as String?)?.isNotEmpty == true
          ? p['category'] as String
          : 'Uncategorized';
      categories[c] = (categories[c] ?? 0) + 1;
    }

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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Could not reach API',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Start backend:\ncd backend && dart run bin/server.dart',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        health != null
                            ? 'API healthy · live data from memory/Firebase store'
                            : 'Live snapshot from the Proxim API',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _StatCard(
                            label: 'Providers',
                            value: '$total',
                            icon: Icons.handyman,
                          ),
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
                          _StatCard(
                            label: 'Categories',
                            value: '${categories.length}',
                            icon: Icons.category_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'By category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (categories.isEmpty)
                        const Text('No providers yet',
                            style: TextStyle(color: Colors.grey))
                      else
                        ...categories.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFE3E2DE)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    '${e.value}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Text(
                        'Demo accounts',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Customer: ada@proxim.ng / password123\n'
                        'Provider:  chinedu@proxim.ng / password123\n\n'
                        'Jobs & wallet require auth — use the mobile app to create requests, accept, complete, and rate.',
                        style: TextStyle(height: 1.55, fontSize: 14, color: Colors.black87),
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
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
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
      appBar: AppBar(
        title: const Text('Providers'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
        ],
      ),
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
                        final name = p['name'] as String? ?? 'Provider';
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE3E2DE)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFE8F5E9),
                                child: Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if ((p['category'] as String?)
                                                ?.isNotEmpty ==
                                            true)
                                          p['category'],
                                        if ((p['city'] as String?)
                                                ?.isNotEmpty ==
                                            true)
                                          p['city'],
                                        if ((p['area'] as String?)
                                                ?.isNotEmpty ==
                                            true)
                                          p['area'],
                                      ].join(' · '),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '★ ${(p['rating'] as num?)?.toStringAsFixed(1) ?? '—'} · ${p['jobsCompleted'] ?? 0} jobs · ₦${_fmt(p['hourlyRate'])}/hr',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: online
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  online ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: online
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey,
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

  String _fmt(dynamic v) {
    if (v == null) return '0';
    return (v as num).toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

class _SettingsPage extends StatelessWidget {
  final String baseUrl;
  final String? health;

  const _SettingsPage({required this.baseUrl, required this.health});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('API', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _infoRow('Base URL', baseUrl),
          _infoRow('Health', health ?? '—'),
          const SizedBox(height: 24),
          Text('Data source', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Set DATA_SOURCE=memory (default) or DATA_SOURCE=firebase when starting the backend.\n'
            'Handlers and repositories never change — only the factory swaps the concrete store.',
            style: TextStyle(height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Text('Mobile', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Android emulator → http://10.0.2.2:8080\n'
            'iOS / desktop → http://localhost:8080\n'
            'Override: flutter run --dart-define=API_BASE=http://HOST:8080',
            style: TextStyle(height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E2DE)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
