import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_with_category.dart';
import 'asset_icon.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.row,
    required this.onDelete,
  });

  final TransactionWithCategory row;
  final VoidCallback onDelete;

  String _categoryAsset(String name) {
    final n = name.toLowerCase();
    if (n.contains('bill') || n.contains('water') || n.contains('electric')) {
      return AppAssets.categoryBills;
    }
    if (n.contains('food') ||
        n.contains('grocery') ||
        n.contains('shop') ||
        n.contains('transport')) {
      return AppAssets.categoryShopping;
    }
    return AppAssets.categoryShopping;
  }

  IconData _categoryFallback(String name) {
    final n = name.toLowerCase();
    if (n.contains('bill') || n.contains('water') || n.contains('electric')) {
      return Icons.opacity;
    }
    if (n.contains('food') || n.contains('grocery')) {
      return Icons.shopping_cart_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final t = row.transaction;
    final isDebit = t.isDebit;
    final amtColor = isDebit ? AppColors.expenseRed : AppColors.incomeGreen;
    final sign = isDebit ? '-' : '+';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AssetIcon(
                asset: _categoryAsset(row.categoryName),
                width: 22,
                height: 22,
                color: Colors.white,
                fallback: _categoryFallback(row.categoryName),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.note.isEmpty ? '—' : t.note,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  row.categoryName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatOrdinalDate(t.createdAt.toLocal()),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$sign${formatInr(t.amount)}',
                style: TextStyle(
                  color: amtColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.expenseRed,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
