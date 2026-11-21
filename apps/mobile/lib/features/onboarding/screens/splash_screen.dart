import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Proxim',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Trusted artisans, on demand',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
