import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/transaction_tile.dart';
import '../../bloc/expense/expense_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAllTransactions});

  final VoidCallback? onSeeAllTransactions;

  @override
  Widget build(BuildContext context) {
    final nick =
        RepositoryProvider.of<PreferencesService>(context).nickname ?? 'User';
    return SafeArea(
      bottom: false,
      child: BlocConsumer<ExpenseBloc, ExpenseState>(
        listenWhen: (p, c) =>
            c.status == ExpenseStatus.failure && c.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        },
        builder: (context, state) {
          final loading =
              state.status == ExpenseStatus.loading && !state.syncing;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    '👋 Welcome, $nick!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (loading)
                SliverToBoxAdapter(child: _HomeShimmer())
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GradientStatCard(
                            gradient: AppColors.incomeCardGradient,
                            label: 'Total Income',
                            amount: state.totalIncome,
                            icon: Icons.south_west,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GradientStatCard(
                            gradient: AppColors.expenseCardGradient,
                            label: 'Total Expense',
                            amount: state.totalExpense,
                            icon: Icons.north_east,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: _MonthlyLimitCard(
                      spent: state.monthlyDebit,
                      limit: state.monthlyLimit,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Recent Transactions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (onSeeAllTransactions != null)
                          TextButton(
                            onPressed: onSeeAllTransactions,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'See All',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (state.recent.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'No transactions yet. Tap + to add one.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      if (i >= state.recent.length) return null;
                      final row = state.recent[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
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
                    childCount: state.recent.isEmpty ? 1 : state.recent.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: AppColors.card,
        highlightColor: AppColors.inputFill,
        child: Column(
          children: [
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 12),
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  const _GradientStatCard({
    required this.gradient,
    required this.label,
    required this.amount,
    required this.icon,
  });

  final LinearGradient gradient;
  final String label;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatInr(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyLimitCard extends StatelessWidget {
  const _MonthlyLimitCard({required this.spent, required this.limit});

  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final remaining = limit <= 0 ? 0.0 : ((limit - spent) / limit * 100).clamp(0.0, 100.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONTHLY LIMIT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatInr(spent)} / ${formatInr(limit)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2A2A),
              color: AppColors.incomeGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${remaining.round()}% Remaining',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
