import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transactions_screen.dart';
import '../add_transaction/add_transaction_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _booted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_booted) {
      _booted = true;
      context.read<ExpenseBloc>().add(const ExpenseStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const TransactionsScreen(),
      ProfileScreen(
        prefs: RepositoryProvider.of<PreferencesService>(context),
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          Positioned.fill(child: pages[_index]),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              buildWhen: (p, c) => p.syncing != c.syncing,
              builder: (context, s) {
                return _BottomNav(
                  index: _index,
                  syncing: s.syncing,
                  onChanged: (i) => setState(() => _index = i),
                  onSync: () {
                    context
                        .read<ExpenseBloc>()
                        .add(const ExpenseSyncRequested());
                  },
                );
              },
            ),
          ),
          if (_index != 2)
            Positioned(
              right: 24,
              bottom: 100,
              child: FloatingActionButton(
                backgroundColor: AppColors.incomeGreen,
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const AddTransactionSheet(),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.onChanged,
    required this.onSync,
    required this.syncing,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onSync;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(40),
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
            icon: Icons.pie_chart_outline,
            onTap: () => onChanged(0),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: syncing ? null : onSync,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: syncing
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync, color: Colors.white),
                ),
              ),
            ),
          ),
          _NavDot(
            active: index == 2,
            icon: Icons.person_outline,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _NavDot extends StatelessWidget {
  const _NavDot({
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? AppColors.primaryBlue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
