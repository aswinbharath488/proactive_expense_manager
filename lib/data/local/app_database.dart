import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/category_entity.dart';
import '../models/transaction_entity.dart';
import '../models/transaction_with_category.dart';

class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  static const _name = 'proactive_expense.db';
  static const _version = 1;

  static Future<AppDatabase> open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _name);
    final db = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE categories (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  is_synced INTEGER NOT NULL DEFAULT 0,
  is_deleted INTEGER NOT NULL DEFAULT 0
);
''');
        await db.execute('''
CREATE TABLE transactions (
  id TEXT NOT NULL PRIMARY KEY,
  amount REAL NOT NULL,
  note TEXT NOT NULL,
  type TEXT NOT NULL,
  category_id TEXT NOT NULL,
  is_synced INTEGER NOT NULL DEFAULT 0,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);
''');
        await db.execute(
          'CREATE INDEX idx_transactions_deleted ON transactions(is_deleted);',
        );
        await db.execute(
          'CREATE INDEX idx_categories_deleted ON categories(is_deleted);',
        );
      },
    );
    return AppDatabase._(db);
  }

  Future<void> close() => _db.close();

  // ——— Categories ———

  Future<void> insertCategory(CategoryEntity c) async {
    await _db.insert(
      'categories',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(CategoryEntity c) async {
    await _db.update(
      'categories',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<List<CategoryEntity>> getCategoriesActive() async {
    final rows = await _db.query(
      'categories',
      where: 'is_deleted = 0',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(CategoryEntity.fromMap).toList();
  }

  Future<List<CategoryEntity>> getCategoriesDeleted() async {
    final rows = await _db.query(
      'categories',
      where: 'is_deleted = 1',
    );
    return rows.map(CategoryEntity.fromMap).toList();
  }

  Future<List<CategoryEntity>> getCategoriesUnsyncedNonDeleted() async {
    final rows = await _db.query(
      'categories',
      where: 'is_synced = 0 AND is_deleted = 0',
    );
    return rows.map(CategoryEntity.fromMap).toList();
  }

  Future<void> hardDeleteCategory(String id) async {
    await _db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markCategorySynced(String id) async {
    await _db.update(
      'categories',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ——— Transactions ———

  Future<void> insertTransaction(TransactionEntity t) async {
    await _db.insert(
      'transactions',
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(TransactionEntity t) async {
    await _db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  /// JOIN query required by skill test: category name for each transaction row.
  Future<List<TransactionWithCategory>> getTransactionsWithCategory({
    int? limit,
    bool activeOnly = true,
  }) async {
    final where = activeOnly ? 't.is_deleted = 0' : '1=1';
    final sql = '''
SELECT t.id, t.amount, t.note, t.type, t.category_id, t.is_synced, t.is_deleted, t.created_at,
       COALESCE(c.name, 'Unknown') AS category_name
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.id
WHERE $where
ORDER BY datetime(t.created_at) DESC
${limit != null ? 'LIMIT $limit' : ''}
''';
    final rows = await _db.rawQuery(sql);
    return rows.map((m) {
      final t = TransactionEntity.fromMap({
        'id': m['id'],
        'amount': m['amount'],
        'note': m['note'],
        'type': m['type'],
        'category_id': m['category_id'],
        'is_synced': m['is_synced'],
        'is_deleted': m['is_deleted'],
        'created_at': m['created_at'],
      });
      return TransactionWithCategory(
        transaction: t,
        categoryName: m['category_name']! as String,
      );
    }).toList();
  }

  Future<List<TransactionEntity>> getTransactionsDeleted() async {
    final rows = await _db.query(
      'transactions',
      where: 'is_deleted = 1',
    );
    return rows.map(TransactionEntity.fromMap).toList();
  }

  Future<List<TransactionEntity>> getTransactionsUnsyncedNonDeleted() async {
    final rows = await _db.query(
      'transactions',
      where: 'is_synced = 0 AND is_deleted = 0',
    );
    return rows.map(TransactionEntity.fromMap).toList();
  }

  Future<void> hardDeleteTransaction(String id) async {
    await _db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markTransactionSynced(String id) async {
    await _db.update(
      'transactions',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> sumAmountByTypeActive(String type) async {
    final rows = await _db.rawQuery(
      '''
SELECT COALESCE(SUM(amount), 0) AS s FROM transactions
WHERE is_deleted = 0 AND type = ?
''',
      [type],
    );
    return (rows.first['s'] as num?)?.toDouble() ?? 0;
  }

  Future<double> sumDebitCurrentMonthActive() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final next = DateTime(now.year, now.month + 1, 1);
    final rows = await _db.rawQuery(
      '''
SELECT COALESCE(SUM(amount), 0) AS s FROM transactions
WHERE is_deleted = 0 AND type = 'debit'
  AND datetime(created_at) >= datetime(?)
  AND datetime(created_at) < datetime(?)
''',
      [start.toIso8601String(), next.toIso8601String()],
    );
    return (rows.first['s'] as num?)?.toDouble() ?? 0;
  }
}
