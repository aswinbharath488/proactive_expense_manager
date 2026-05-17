import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import 'asset_icon.dart';

/// Bottom bar: home, sync (center), profile.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.syncing,
    required this.onTabChanged,
    required this.onSync,
  });

  final int index;
  final bool syncing;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onSync;

  static const _activeDotSize = 52.0;
  static const _inactiveDotSize = 44.0;
  static const _activeIconSize = 28.0;
  static const _inactiveIconSize = 24.0;
  static const _syncButtonSize = 56.0;
  static const _syncIconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavDot(
            active: index == 0,
            asset: AppAssets.navHome,
            fallback: Icons.pie_chart_outline,
            onTap: () => onTabChanged(0),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: syncing ? null : onSync,
                child: Container(
                  width: _syncButtonSize,
                  height: _syncButtonSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: syncing
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Center(
                          child: AssetIcon(
                            asset: AppAssets.navSync,
                            width: _syncIconSize,
                            height: _syncIconSize,
                            color: Colors.white,
                            fallback: Icons.sync,
                          ),
                        ),
                ),
              ),
            ),
          ),
          _NavDot(
            active: index == 2,
            asset: AppAssets.navProfile,
            fallback: Icons.person_outline,
            onTap: () => onTabChanged(2),
          ),
        ],
      ),
    );
  }
}

class _NavDot extends StatelessWidget {
  const _NavDot({
    required this.active,
    required this.asset,
    required this.fallback,
    required this.onTap,
  });

  final bool active;
  final String asset;
  final IconData fallback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dotSize =
        active ? AppBottomNav._activeDotSize : AppBottomNav._inactiveDotSize;
    final iconSize =
        active ? AppBottomNav._activeIconSize : AppBottomNav._inactiveIconSize;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AssetIcon(
              asset: asset,
              width: iconSize,
              height: iconSize,
              color: Colors.white,
              fallback: fallback,
            ),
          ),
        ),
      ),
    );
  }
}
