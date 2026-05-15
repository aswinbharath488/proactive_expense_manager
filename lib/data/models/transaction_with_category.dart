import 'package:equatable/equatable.dart';

import 'transaction_entity.dart';

/// Row from SQL JOIN between transactions and categories.
class TransactionWithCategory extends Equatable {
  const TransactionWithCategory({
    required this.transaction,
    required this.categoryName,
  });

  final TransactionEntity transaction;
  final String categoryName;

  @override
  List<Object?> get props => [transaction, categoryName];
}
