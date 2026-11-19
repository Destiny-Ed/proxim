import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';
import 'provider_setup_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = context.read<AppState>().user;
      if (user == null) return;
      final p = await context.read<AppState>().api.getProvider(user['id']);
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _profile = null;
        _loading = false;
      });
    }
  }

  Future<void> _toggleOnline(bool value) async {
    setState(() => _toggling = true);
    try {
      final updated = await context.read<AppState>().api.setOnline(value);
      setState(() => _profile = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProviderSetupScreen()),
              );
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Hello, ${user?['name']?.toString().split(' ').first ?? 'there'} 👋',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your availability and jobs',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  NotionCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Go online', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                _profile?['isOnline'] == true
                                    ? 'Customers can find and request you'
                                    : 'You are currently offline',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (_toggling)
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Switch(
                            value: _profile?['isOnline'] == true,
                            onChanged: _profile == null ? null : _toggleOnline,
                            activeColor: AppTheme.accent,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_profile != null) ...[
                    NotionCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _stat('Rating', '${_profile!['rating'] ?? 0}'),
                          _stat('Reviews', '${_profile!['reviewCount'] ?? 0}'),
                          _stat('Jobs done', '${_profile!['jobsCompleted'] ?? 0}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    NotionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_profile!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(_profile!['category'] ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                          if ((_profile!['bio'] as String?)?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            Text(_profile!['bio'], style: const TextStyle(fontSize: 14, height: 1.4)),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '₦${_fmt(_profile!['hourlyRate'])}/hr · ${_profile!['area'] ?? ''} ${_profile!['city'] ?? ''}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    NotionCard(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProviderSetupScreen()),
                        );
                        _load();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: AppTheme.accent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Complete your provider profile to start receiving jobs',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final n = (v as num).toInt();
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
