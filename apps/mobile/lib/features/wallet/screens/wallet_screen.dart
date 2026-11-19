import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _wallet;
  List<dynamic> _txs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = context.read<AppState>().api;
      final w = await api.getWallet();
      final t = await api.transactions();
      setState(() {
        _wallet = w;
        _txs = t;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _topUp() async {
    final ctrl = TextEditingController(text: '5000');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Top up wallet'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₦ ', labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Top up')),
        ],
      ),
    );
    if (ok == true) {
      final amount = double.tryParse(ctrl.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) return;
      try {
        await context.read<AppState>().api.topUp(amount, reference: 'DEMO-${DateTime.now().millisecondsSinceEpoch}');
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet topped up')));
        }
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
      appBar: AppBar(
        title: Text(isProvider ? 'Earnings' : 'Wallet'),
        actions: [
          if (!isProvider)
            TextButton(onPressed: _topUp, child: const Text('Top up')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  NotionCard(
                    color: AppTheme.accent,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProvider ? 'Available balance' : 'Wallet balance',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₦${_fmt(_wallet?['balance'])}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _wallet?['currency'] ?? 'NGN',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Transactions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 10),
                  if (_txs.isEmpty)
                    const NotionCard(
                      child: Text('No transactions yet', style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  else
                    ..._txs.map((t) {
                      final m = t as Map<String, dynamic>;
                      final isCredit = m['type'] == 'credit';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: NotionCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCredit ? AppTheme.accentSoft : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: isCredit ? AppTheme.accent : AppTheme.danger,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m['note'] ?? m['type'] ?? 'Transaction',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      _shortDate(m['createdAt']),
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}₦${_fmt(m['amount'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isCredit ? AppTheme.accent : AppTheme.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
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
