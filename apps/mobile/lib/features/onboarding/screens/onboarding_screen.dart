import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  final _slides = const [
    _Slide(
      icon: Icons.search_rounded,
      title: 'Find artisans near you',
      body:
          'Search plumbers, electricians, stylists and more. Online providers show first — closest to you next.',
    ),
    _Slide(
      icon: Icons.toggle_on_rounded,
      title: 'Providers go online',
      body:
          'Like a ride app: artisans toggle availability. You only see who is free to take the job now.',
    ),
    _Slide(
      icon: Icons.timeline_rounded,
      title: 'Track every request',
      body:
          'From pending to completed on a clear timeline. Pay from your wallet, rate when done.',
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AppState>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.accentSoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(s.icon, size: 48, color: AppTheme.accent),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AppTheme.accent : AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: ElevatedButton(
                onPressed: () {
                  if (_index < _slides.length - 1) {
                    _page.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(_index < _slides.length - 1 ? 'Continue' : 'Get started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.title, required this.body});
}
