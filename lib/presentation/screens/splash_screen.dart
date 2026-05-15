import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_screen.dart';
import 'auth/phone_login_screen.dart';
import 'shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final p = widget.prefs;
    final hasToken = p.authToken != null && p.authToken!.isNotEmpty;
    if (hasToken) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
    } else if (!p.onboardingComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => OnboardingScreen(prefs: p)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => PhoneLoginScreen(prefs: p)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: Image.asset(
          'assets/images/Logo.png',
          width: 132,
          height: 132,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
