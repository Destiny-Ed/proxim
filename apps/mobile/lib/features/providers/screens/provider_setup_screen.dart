import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';

class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _city = TextEditingController(text: 'Port Harcourt');
  final _area = TextEditingController();
  final _rate = TextEditingController();
  final _services = TextEditingController();
  String _category = 'Plumbing';
  bool _loading = false;
  bool _saving = false;

  final _categories = [
    'Plumbing',
    'Electrical',
    'Beauty & Hair',
    'Cleaning',
    'Car Wash',
    'Carpentry',
    'Painting',
    'AC Repair',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    setState(() => _loading = true);
    try {
      final user = context.read<AppState>().user;
      if (user == null) return;
      final p = await context.read<AppState>().api.getProvider(user['id']);
      _name.text = p['name'] ?? user['name'] ?? '';
      _bio.text = p['bio'] ?? '';
      _city.text = p['city'] ?? 'Port Harcourt';
      _area.text = p['area'] ?? '';
      _rate.text = (p['hourlyRate'] as num?)?.toString() ?? '';
      _category = p['category']?.toString().isNotEmpty == true ? p['category'] : 'Plumbing';
      final services = (p['services'] as List?)?.cast<String>() ?? [];
      _services.text = services.join(', ');
    } catch (_) {
      final user = context.read<AppState>().user;
      _name.text = user?['name'] ?? '';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _city.dispose();
    _area.dispose();
    _rate.dispose();
    _services.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final services = _services.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      await context.read<AppState>().api.upsertProviderProfile({
        'name': _name.text.trim(),
        'bio': _bio.text.trim(),
        'city': _city.text.trim(),
        'area': _area.text.trim(),
        'category': _category,
        'hourlyRate': double.tryParse(_rate.text) ?? 0,
        'services': services,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display name')),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _bio,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true),
                ),
                const SizedBox(height: 14),
                TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
                const SizedBox(height: 14),
                TextField(controller: _area, decoration: const InputDecoration(labelText: 'Area / Neighbourhood')),
                const SizedBox(height: 14),
                TextField(
                  controller: _rate,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hourly rate (₦)', prefixText: '₦ '),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _services,
                  decoration: const InputDecoration(
                    labelText: 'Services (comma separated)',
                    hintText: 'Pipe repair, Water heater, ...',
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save profile'),
                ),
              ],
            ),
    );
  }
}
