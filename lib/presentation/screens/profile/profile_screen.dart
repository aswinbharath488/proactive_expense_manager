import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/asset_icon.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../auth/phone_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nick;
  late final TextEditingController _limit;
  late final TextEditingController _newCat;

  @override
  void initState() {
    super.initState();
    _nick = TextEditingController(text: widget.prefs.nickname ?? '');
    _limit = TextEditingController();
    _newCat = TextEditingController();
  }

  @override
  void dispose() {
    _nick.dispose();
    _limit.dispose();
    _newCat.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthRepository>().logout();
    if (!context.mounted) return;
    context.read<AuthBloc>().add(const AuthReset());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => PhoneLoginScreen(prefs: widget.prefs),
      ),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
              const Text(
                'Profile & Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('NICKNAME'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nick,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your name',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ExpenseBloc>().add(
                              ExpenseNicknameUpdated(_nick.text),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nickname saved')),
                        );
                      },
                      icon: const AssetIcon(
                        asset: AppAssets.iconEdit,
                        width: 22,
                        height: 22,
                        color: Colors.white,
                        fallback: Icons.edit_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('ALERT LIMIT (₹)'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _limit,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Amount (₹)',
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          width: 72,
                          child: ElevatedButton(
                            onPressed: () {
                              final v = double.tryParse(_limit.text.trim());
                              if (v == null || v <= 0) return;
                              context.read<ExpenseBloc>().add(
                                    ExpenseMonthlyLimitUpdated(v),
                                  );
                              _limit.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Limit updated')),
                              );
                            },
                            child: const Text('Set'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Limit: ${formatInr(state.monthlyLimit)}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('CATEGORIES'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCat,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'New category Name',
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 52,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              final n = _newCat.text.trim();
                              if (n.isEmpty) return;
                              context.read<ExpenseBloc>().add(
                                    ExpenseAddCategory(n),
                                  );
                              _newCat.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...state.categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.expenseRed),
                                minimumSize: const Size(44, 40),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                context.read<ExpenseBloc>().add(
                                      ExpenseDeleteCategory(c.id),
                                    );
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.expenseRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('CLOUD SYNC'),
              const SizedBox(height: 8),
              Material(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: state.syncing
                      ? null
                      : () {
                          context
                              .read<ExpenseBloc>()
                              .add(const ExpenseSyncRequested());
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sync To Cloud',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.syncing
                                    ? 'Syncing…'
                                    : 'Sync and update data to the backend',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        state.syncing
                            ? const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : AssetIcon(
                                asset: AppAssets.iconCloudSync,
                                width: 32,
                                height: 32,
                                color: Colors.white.withValues(alpha: 0.9),
                                fallback: Icons.cloud_upload_outlined,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.expenseRed),
                  foregroundColor: AppColors.expenseRed,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () => _logout(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.power_settings_new),
                  ],
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
