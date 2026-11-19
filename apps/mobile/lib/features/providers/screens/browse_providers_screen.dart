import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';
import 'provider_detail_screen.dart';

class BrowseProvidersScreen extends StatefulWidget {
  const BrowseProvidersScreen({super.key});

  @override
  State<BrowseProvidersScreen> createState() => _BrowseProvidersScreenState();
}

class _BrowseProvidersScreenState extends State<BrowseProvidersScreen> {
  List<dynamic> _providers = [];
  bool _loading = true;
  String? _error;
  String _category = '';
  bool _onlineOnly = false;

  final _categories = [
    'All',
    'Plumbing',
    'Electrical',
    'Beauty & Hair',
    'Cleaning',
    'Car Wash',
  ];

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
      final api = context.read<AppState>().api;
      final list = await api.listProviders(
        category: _category.isEmpty || _category == 'All' ? null : _category,
        onlineOnly: _onlineOnly,
      );
      setState(() {
        _providers = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find artisans'),
        actions: [
          IconButton(
            icon: Icon(_onlineOnly ? Icons.toggle_on : Icons.toggle_off_outlined,
                color: _onlineOnly ? AppTheme.accent : null),
            tooltip: 'Online only',
            onPressed: () {
              setState(() => _onlineOnly = !_onlineOnly);
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = (_category.isEmpty && cat == 'All') || _category == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _category = cat == 'All' ? '' : cat);
                    _load();
                  },
                  selectedColor: AppTheme.accentSoft,
                  checkmarkColor: AppTheme.accent,
                  side: BorderSide(color: selected ? AppTheme.accent : AppTheme.border),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _providers.isEmpty
                        ? const Center(child: Text('No providers found'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _providers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final p = _providers[i] as Map<String, dynamic>;
                                return NotionCard(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProviderDetailScreen(providerId: p['id']),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: AppTheme.accentSoft,
                                        child: Text(
                                          (p['name'] as String? ?? '?')[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.accent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    p['name'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                OnlineBadge(isOnline: p['isOnline'] == true),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${p['category'] ?? ''} · ${p['area'] ?? p['city'] ?? ''}',
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, size: 16, color: AppTheme.warning),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${p['rating'] ?? 0} (${p['reviewCount'] ?? 0})',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '₦${_fmt(p['hourlyRate'])}/hr',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.accent,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final n = (v as num).toInt();
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
