part of 'expense_bloc.dart';

enum ExpenseStatus { initial, loading, ready, failure }

class ExpenseState extends Equatable {
  const ExpenseState({
    required this.status,
    required this.initialLoad,
    required this.errorMessage,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyDebit,
    required this.monthlyLimit,
    required this.recent,
    required this.all,
    required this.categories,
    required this.syncing,
  });

  const ExpenseState.initial()
      : status = ExpenseStatus.initial,
        initialLoad = true,
        errorMessage = null,
        totalIncome = 0,
        totalExpense = 0,
        monthlyDebit = 0,
        monthlyLimit = 10000,
        recent = const [],
        all = const [],
        categories = const [],
        syncing = false;

  final ExpenseStatus status;
  final bool initialLoad;
  final String? errorMessage;
  final double totalIncome;
  final double totalExpense;
  final double monthlyDebit;
  final double monthlyLimit;
  final List<TransactionWithCategory> recent;
  final List<TransactionWithCategory> all;
  final List<CategoryEntity> categories;
  final bool syncing;

  ExpenseState copyWith({
    ExpenseStatus? status,
    bool? initialLoad,
    String? errorMessage,
    bool preserveError = true,
    double? totalIncome,
    double? totalExpense,
    double? monthlyDebit,
    double? monthlyLimit,
    List<TransactionWithCategory>? recent,
    List<TransactionWithCategory>? all,
    List<CategoryEntity>? categories,
    bool? syncing,
  }) {
    final String? nextError;
    if (errorMessage != null) {
      nextError = errorMessage;
    } else if (preserveError) {
      nextError = this.errorMessage;
    } else {
      nextError = null;
    }
    return ExpenseState(
      status: status ?? this.status,
      initialLoad: initialLoad ?? this.initialLoad,
      errorMessage: nextError,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      monthlyDebit: monthlyDebit ?? this.monthlyDebit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      recent: recent ?? this.recent,
      all: all ?? this.all,
      categories: categories ?? this.categories,
      syncing: syncing ?? this.syncing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialLoad,
        errorMessage,
        totalIncome,
        totalExpense,
        monthlyDebit,
        monthlyLimit,
        recent,
        all,
        categories,
        syncing,
      ];
}
