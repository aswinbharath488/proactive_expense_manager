import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final loading =
              state.status == ExpenseStatus.loading && !state.syncing;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
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
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        itemCount: state.all.length,
                        itemBuilder: (context, i) {
                          final row = state.all[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(
                              row: row,
                              onDelete: () {
                                context.read<ExpenseBloc>().add(
                                      ExpenseDeleteTransaction(row.transaction.id),
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
    );
  }
}
