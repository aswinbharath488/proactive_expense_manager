import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            final loading =
                state.status == ExpenseStatus.loading && !state.syncing;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                  child: Row(
                    children: [
                      if (showBackButton)
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.inputFill,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.chevron_left, size: 28),
                        ),
                      const Expanded(
                        child: Text(
                          'Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Shimmer.fromColors(
                            baseColor: AppColors.card,
                            highlightColor: AppColors.inputFill,
                            child: ListView.separated(
                              itemCount: 8,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => Container(
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        )
                      : state.all.isEmpty
                          ? const Center(
                              child: Text(
                                'No transactions yet.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 120),
                              itemCount: state.all.length,
                              itemBuilder: (context, i) {
                                final row = state.all[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TransactionTile(
                                    row: row,
                                    onDelete: () {
                                      context.read<ExpenseBloc>().add(
                                            ExpenseDeleteTransaction(
                                              row.transaction.id,
                                            ),
                                          );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
