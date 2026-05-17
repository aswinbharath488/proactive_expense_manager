import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../widgets/app_bottom_nav.dart';
import '../add_transaction/add_transaction_sheet.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transactions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// Figma tabs: `0` = Home, `2` = Profile (center button is sync).
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

  void _openAllTransactions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TransactionsScreen(showBackButton: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _index == 2
        ? ProfileScreen(
            prefs: RepositoryProvider.of<PreferencesService>(context),
          )
        : HomeScreen(onSeeAllTransactions: _openAllTransactions);

    return BlocListener<ExpenseBloc, ExpenseState>(
      listenWhen: (p, c) => p.syncing && !c.syncing,
      listener: (context, state) {
        if (state.status == ExpenseStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.status == ExpenseStatus.ready) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sync completed')),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              buildWhen: (p, c) => p.syncing != c.syncing,
              builder: (context, state) {
                return AppBottomNav(
                  index: _index,
                  syncing: state.syncing,
                  onTabChanged: (i) => setState(() => _index = i),
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
                elevation: 6,
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const AddTransactionSheet(),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
