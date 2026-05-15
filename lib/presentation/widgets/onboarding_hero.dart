import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Hero illustration: shield + lock + bokeh (no raster asset required).
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.42,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A1628), Color(0xFF050508)],
                ),
              ),
            ),
            ...List.generate(8, (i) {
              return Positioned(
                left: (i * 47.0) % 320,
                top: (i * 31.0) % 180,
                child: Container(
                  width: 40 + i * 6.0,
                  height: 40 + i * 6.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.logoBlue.withValues(alpha: 0.08 + i * 0.01),
                  ),
                ),
              );
            }),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
            Center(
              child: Container(
                width: 140,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.logoBlue.withValues(alpha: 0.55),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 150,
                      color: AppColors.logoBlue.withValues(alpha: 0.95),
                    ),
                    const Icon(
                      Icons.lock_rounded,
                      size: 56,
                      color: Color(0xFF0B1B3A),
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
