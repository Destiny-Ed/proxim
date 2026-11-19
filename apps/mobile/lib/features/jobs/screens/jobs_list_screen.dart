import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';
import 'job_detail_screen.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  List<dynamic> _jobs = [];
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
      final list = await context.read<AppState>().api.listJobs();
      setState(() {
        _jobs = list;
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
    final isProvider = context.watch<AppState>().isProvider;
    return Scaffold(
      appBar: AppBar(
        title: Text(isProvider ? 'Job requests' : 'My requests'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _loading
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
              : _jobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            isProvider ? 'No job requests yet' : 'No requests yet',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _jobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final j = _jobs[i] as Map<String, dynamic>;
                          return NotionCard(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(jobId: j['id']),
                                ),
                              );
                              _load();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        j['title'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                    ),
                                    StatusChip(status: j['status'] ?? 'pending'),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isProvider
                                      ? 'From ${j['customerName'] ?? 'Customer'}'
                                      : 'To ${j['providerName'] ?? 'Provider'}',
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '₦${_fmt(j['budget'])}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _shortDate(j['createdAt']),
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
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
    final n = (v as num).toInt();
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  String _shortDate(dynamic v) {
    if (v == null) return '';
    try {
      final d = DateTime.parse(v.toString());
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'accepted':
        bg = const Color(0xFFE3F2FD);
        fg = AppTheme.info;
        break;
      case 'in_progress':
        bg = AppTheme.accentSoft;
        fg = AppTheme.accent;
        break;
      case 'completed':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
        bg = const Color(0xFFFFEBEE);
        fg = AppTheme.danger;
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        fg = AppTheme.warning;
    }
    final label = status == 'in_progress' ? 'In progress' : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
