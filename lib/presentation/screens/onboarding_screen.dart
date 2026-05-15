import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/onboarding_hero.dart';
import 'auth/phone_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardPage>[
    _OnboardPage(
      title: 'Privacy by Default, With Zero Ads or Hidden Tracking',
      subtitle: 'No ads. No trackers. No third-party analytics.',
    ),
    _OnboardPage(
      title: 'Insights That Help You Spend Better Without Complexity',
      subtitle: 'See category-wise spending, recent activity.',
    ),
    _OnboardPage(
      title: 'Local-First Tracking That Stays Fully On Your Device',
      subtitle: 'Your finances stay on your phone.',
    ),
  ];

  void _finish() async {
    await widget.prefs.setOnboardingComplete(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PhoneLoginScreen(prefs: widget.prefs),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Stack(
              children: [
                const OnboardingHero(),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 16,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PageDots(
                      count: _pages.length,
                      index: _page,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, i) {
                          final p = _pages[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                p.subtitle,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (_page == 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryIndigo,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: const Text('Next'),
                        ),
                      )
                    else
                      Row(
                        children: [
                          _CircleBack(
                            onPressed: () {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_page == _pages.length - 1) {
                                  _finish();
                                } else {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 320),
                                    curve: Curves.easeOutCubic,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryIndigo,
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: Text(
                                _page == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }
}
