part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class ExpenseStarted extends ExpenseEvent {
  const ExpenseStarted();
}

class ExpenseRefreshed extends ExpenseEvent {
  const ExpenseRefreshed();
}

class ExpenseAddTransaction extends ExpenseEvent {
  const ExpenseAddTransaction({
    required this.note,
    required this.amount,
    required this.type,
    required this.categoryId,
  });

  final String note;
  final double amount;
  final String type;
  final String categoryId;

  @override
  List<Object?> get props => [note, amount, type, categoryId];
}

class ExpenseDeleteTransaction extends ExpenseEvent {
  const ExpenseDeleteTransaction(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ExpenseAddCategory extends ExpenseEvent {
  const ExpenseAddCategory(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

class ExpenseDeleteCategory extends ExpenseEvent {
  const ExpenseDeleteCategory(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ExpenseSyncRequested extends ExpenseEvent {
  const ExpenseSyncRequested();
}

class ExpenseNicknameUpdated extends ExpenseEvent {
  const ExpenseNicknameUpdated(this.nickname);
  final String nickname;

  @override
  List<Object?> get props => [nickname];
}

class ExpenseMonthlyLimitUpdated extends ExpenseEvent {
  const ExpenseMonthlyLimitUpdated(this.limit);
  final double limit;

  @override
  List<Object?> get props => [limit];
}
