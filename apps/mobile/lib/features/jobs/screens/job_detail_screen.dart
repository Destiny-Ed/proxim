import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';
import 'jobs_list_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? _job;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final j = await context.read<AppState>().api.getJob(widget.jobId);
      setState(() {
        _job = j;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _updateStatus(String status, {String? note}) async {
    setState(() => _acting = true);
    try {
      await context.read<AppState>().api.updateJobStatus(widget.jobId, status, note: note);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _rate() async {
    int rating = 5;
    final reviewCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Rate this job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppTheme.warning,
                    ),
                    onPressed: () => setS(() => rating = i + 1),
                  );
                }),
              ),
              TextField(
                controller: reviewCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Optional review'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      ),
    );
    if (ok == true) {
      try {
        await context.read<AppState>().api.rateJob(widget.jobId, rating, review: reviewCtrl.text.trim());
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = context.watch<AppState>().isProvider;
    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: _loading || _job == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                NotionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _job!['title'] ?? '',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          StatusChip(status: _job!['status'] ?? 'pending'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_job!['description'] ?? ''),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '₦${_fmt(_job!['budget'])}',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent),
                          ),
                        ],
                      ),
                      if ((_job!['address'] as String?)?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(child: Text(_job!['address'])),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                NotionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Timeline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 12),
                      ...((_job!['timeline'] as List?) ?? []).map((t) {
                        final m = t as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (m['status'] as String? ?? '').replaceAll('_', ' ').toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    if (m['note'] != null)
                                      Text(m['note'], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                    Text(
                                      _formatTime(m['at']),
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
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
                if (_job!['rating'] != null) ...[
                  const SizedBox(height: 12),
                  NotionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your rating', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < (_job!['rating'] as int)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: AppTheme.warning,
                              size: 22,
                            ),
                          ),
                        ),
                        if (_job!['review'] != null) ...[
                          const SizedBox(height: 6),
                          Text(_job!['review']),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_acting)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._actions(isProvider),
              ],
            ),
    );
  }

  List<Widget> _actions(bool isProvider) {
    final status = _job!['status'] as String? ?? '';
    final widgets = <Widget>[];

    if (isProvider) {
      if (status == 'pending') {
        widgets.addAll([
          ElevatedButton(
            onPressed: () => _updateStatus('accepted', note: 'Accepted by provider'),
            child: const Text('Accept job'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _updateStatus('rejected', note: 'Declined by provider'),
            child: const Text('Decline'),
          ),
        ]);
      } else if (status == 'accepted') {
        widgets.add(
          ElevatedButton(
            onPressed: () => _updateStatus('in_progress', note: 'Work started'),
            child: const Text('Start work'),
          ),
        );
      } else if (status == 'in_progress') {
        widgets.add(
          ElevatedButton(
            onPressed: () => _updateStatus('completed', note: 'Job completed'),
            child: const Text('Mark completed'),
          ),
        );
      }
    } else {
      if (status == 'pending') {
        widgets.add(
          OutlinedButton(
            onPressed: () => _updateStatus('cancelled', note: 'Cancelled by customer'),
            child: const Text('Cancel request'),
          ),
        );
      } else if (status == 'completed' && _job!['rating'] == null) {
        widgets.add(
          ElevatedButton(onPressed: _rate, child: const Text('Rate this job')),
        );
      }
    }
    return widgets;
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    return (v as num).toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _formatTime(dynamic iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso as String).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
