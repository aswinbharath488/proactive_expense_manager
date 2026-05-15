import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/expense/expense_bloc.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  bool _expense = true;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cats = context.read<ExpenseBloc>().state.categories;
      if (mounted && _categoryId == null && cats.isNotEmpty) {
        setState(() => _categoryId = cats.first.id);
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add Transaction',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        color: const Color(0xFF1A1A1A),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ToggleChip(
                              label: 'Expense',
                              selected: _expense,
                              selectedColor: AppColors.incomeGreen,
                              onTap: () => setState(() => _expense = true),
                            ),
                          ),
                          Expanded(
                            child: _ToggleChip(
                              label: 'Income',
                              selected: !_expense,
                              selectedColor: AppColors.inputFill,
                              onTap: () => setState(() => _expense = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _title,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Amount (₹)',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CATEGORY',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final c = state.categories[i];
                          final sel = _categoryId == c.id;
                          return ChoiceChip(
                            label: Text(c.name),
                            selected: sel,
                            onSelected: (_) =>
                                setState(() => _categoryId = c.id),
                            selectedColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: sel ? AppColors.primaryBlue : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: sel ? AppColors.primaryBlue : AppColors.border,
                              ),
                            ),
                            backgroundColor: AppColors.inputFill,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10321E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white70),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Everything you add here is saved only on your device.',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        final amt = double.tryParse(_amount.text.trim());
                        if (amt == null ||
                            amt <= 0 ||
                            _title.text.trim().isEmpty ||
                            _categoryId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter title, amount, and category'),
                            ),
                          );
                          return;
                        }
                        final type = _expense ? 'debit' : 'credit';
                        context.read<ExpenseBloc>().add(
                              ExpenseAddTransaction(
                                note: _title.text.trim(),
                                amount: amt,
                                type: type,
                                categoryId: _categoryId!,
                              ),
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
