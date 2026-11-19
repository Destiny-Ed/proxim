import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';
import '../../providers/screens/provider_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NotionCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.accentSoft,
                  child: Text(
                    (user['name'] as String? ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.accent),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (user['role'] as String? ?? '').toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (state.isProvider)
            NotionCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProviderSetupScreen()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
                  SizedBox(width: 12),
                  Expanded(child: Text('Edit provider profile')),
                  Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                ],
              ),
            ),
          if (state.isProvider) const SizedBox(height: 10),
          NotionCard(
            child: Column(
              children: [
                _row(Icons.phone_outlined, 'Phone', user['phone'] ?? '—'),
                const Divider(height: 24),
                _row(Icons.badge_outlined, 'User ID', user['id'] ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await state.logout();
            },
            icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
            label: const Text('Sign out', style: TextStyle(color: AppTheme.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
