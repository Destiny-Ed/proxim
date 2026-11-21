import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/notion_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'App',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          NotionCard(
            child: Column(
              children: [
                _tile(
                  Icons.notifications_outlined,
                  'Notifications',
                  'Job updates & messages',
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                const Divider(height: 1),
                _tile(
                  Icons.language_rounded,
                  'Language',
                  'English (NG)',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Location',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          NotionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tile(
                  Icons.place_outlined,
                  'Search near',
                  'Port Harcourt (demo)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'GPS coming soon — using PH centre for proximity',
                        ),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Online artisans closest to you are ranked first when browsing.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'About',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          NotionCard(
            child: Column(
              children: [
                _tile(Icons.info_outline_rounded, 'Version', '1.0.0'),
                const Divider(height: 1),
                _tile(Icons.cloud_outlined, 'API', ApiService.baseUrl),
                const Divider(height: 1),
                _tile(
                  Icons.help_outline_rounded,
                  'Help & support',
                  'Demo: ada@ / chinedu@ proxim.ng',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text('You can sign back in anytime.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(color: AppTheme.danger),
                      ),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await state.logout();
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
            label: const Text(
              'Sign out',
              style: TextStyle(color: AppTheme.danger),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
              : null),
      onTap: onTap,
    );
  }
}
