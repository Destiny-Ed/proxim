import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';
import '../../jobs/screens/create_job_screen.dart';

class ProviderDetailScreen extends StatefulWidget {
  final String providerId;
  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  Map<String, dynamic>? _provider;
  bool _loading = true;
  String? _error;

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
      final p = await context.read<AppState>().api.getProvider(widget.providerId);
      setState(() {
        _provider = p;
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
      appBar: AppBar(title: Text(_provider?['name'] ?? 'Provider')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
      bottomNavigationBar: _provider == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton(
                  onPressed: _provider!['isOnline'] != true
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CreateJobScreen(provider: _provider!),
                            ),
                          );
                        },
                  child: Text(
                    _provider!['isOnline'] == true ? 'Request this artisan' : 'Currently offline',
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    final p = _provider!;
    final services = (p['services'] as List?)?.cast<String>() ?? [];
    final portfolio = (p['portfolio'] as List?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NotionCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.accentSoft,
                child: Text(
                  (p['name'] as String)[0].toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.accent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('${p['category']} · ${p['area'] ?? p['city']}',
                        style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    OnlineBadge(isOnline: p['isOnline'] == true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NotionCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('Rating', '${p['rating'] ?? 0}'),
              _stat('Reviews', '${p['reviewCount'] ?? 0}'),
              _stat('Jobs', '${p['jobsCompleted'] ?? 0}'),
              _stat('Rate', '₦${_fmt(p['hourlyRate'])}'),
            ],
          ),
        ),
        if ((p['bio'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          NotionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                Text(p['bio'], style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
        ],
        if (services.isNotEmpty) ...[
          const SizedBox(height: 12),
          NotionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Services', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: services
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 13)),
                            backgroundColor: AppTheme.bg,
                            side: const BorderSide(color: AppTheme.border),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        if (portfolio.isNotEmpty) ...[
          const SizedBox(height: 12),
          NotionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Portfolio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                ...portfolio.map((item) {
                  final m = item as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Icon(Icons.image_outlined, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (m['description'] != null)
                                Text(m['description'],
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
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
