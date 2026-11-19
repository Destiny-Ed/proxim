import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';

class CreateJobScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  const CreateJobScreen({super.key, required this.provider});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _budget = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _budget.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final budget = double.tryParse(_budget.text.replaceAll(',', ''));
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty || budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title, description and a valid budget')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AppState>().api.createJob({
        'providerId': widget.provider['id'],
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'budget': budget,
        'address': _address.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent!')),
        );
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'To ${widget.provider['name']}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            widget.provider['category'] ?? '',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'What do you need?',
              hintText: 'e.g. Fix leaking kitchen sink',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Details',
              hintText: 'Describe the problem, preferred time, any materials...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget (₦)',
              hintText: '15000',
              prefixText: '₦ ',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'Street, area, landmark',
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send request'),
          ),
        ],
      ),
    );
  }
}
