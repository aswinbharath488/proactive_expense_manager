import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.isSynced,
    required this.isDeleted,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String note;
  /// `credit` (income) or `debit` (expense) per API contract.
  final String type;
  final String categoryId;
  final bool isSynced;
  final bool isDeleted;
  final DateTime createdAt;

  bool get isDebit => type == 'debit';
  bool get isCredit => type == 'credit';

  TransactionEntity copyWith({
    String? id,
    double? amount,
    String? note,
    String? type,
    String? categoryId,
    bool? isSynced,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TransactionEntity.fromMap(Map<String, Object?> map) {
    return TransactionEntity(
      id: map['id']! as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note']! as String,
      type: map['type']! as String,
      categoryId: map['category_id']! as String,
      isSynced: (map['is_synced'] as int) == 1,
      isDeleted: (map['is_deleted'] as int) == 1,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'amount': amount,
        'note': note,
        'type': type,
        'category_id': categoryId,
        'is_synced': isSynced ? 1 : 0,
        'is_deleted': isDeleted ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, amount, note, type, categoryId, isSynced, isDeleted, createdAt];
}
