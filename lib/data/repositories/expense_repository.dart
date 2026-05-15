import 'package:uuid/uuid.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/preferences_service.dart';
import '../api/api_client.dart';
import '../local/app_database.dart';
import '../models/category_entity.dart';
import '../models/transaction_entity.dart';
import '../models/transaction_with_category.dart';

class ExpenseRepository {
  ExpenseRepository(this._db, this._api, this._prefs);

  final AppDatabase _db;
  final ApiClient _api;
  final PreferencesService _prefs;
  static const _uuid = Uuid();

  Future<void> ensureDefaultCategories() async {
    final active = await _db.getCategoriesActive();
    if (active.isNotEmpty) return;
    const names = ['Food', 'Bills', 'Transport', 'Shopping'];
    for (final n in names) {
      await _db.insertCategory(
        CategoryEntity(
          id: _uuid.v4(),
          name: n,
          isSynced: false,
          isDeleted: false,
        ),
      );
    }
  }

  Future<List<CategoryEntity>> activeCategories() =>
      _db.getCategoriesActive();

  Future<List<TransactionWithCategory>> recentTransactions({int limit = 10}) =>
      _db.getTransactionsWithCategory(limit: limit, activeOnly: true);

  Future<List<TransactionWithCategory>> allTransactions() =>
      _db.getTransactionsWithCategory(activeOnly: true);

  Future<double> totalIncome() => _db.sumAmountByTypeActive('credit');

  Future<double> totalExpense() => _db.sumAmountByTypeActive('debit');

  Future<double> monthlyDebitTotal() => _db.sumDebitCurrentMonthActive();

  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _db.insertCategory(
      CategoryEntity(
        id: _uuid.v4(),
        name: trimmed,
        isSynced: false,
        isDeleted: false,
      ),
    );
  }

  Future<void> softDeleteCategory(String id) async {
    final list = await _db.getCategoriesActive();
    CategoryEntity? existing;
    for (final c in list) {
      if (c.id == id) {
        existing = c;
        break;
      }
    }
    if (existing == null) return;
    await _db.updateCategory(
      existing.copyWith(isDeleted: true, isSynced: false),
    );
  }

  Future<void> updateNicknameLocal(String nickname) =>
      _prefs.setNickname(nickname);

  Future<void> setMonthlyLimit(double amount) =>
      _prefs.setMonthlyExpenseLimit(amount);

  double get monthlyLimit => _prefs.monthlyExpenseLimit;

  Future<void> addTransaction({
    required String note,
    required double amount,
    required String type,
    required String categoryId,
  }) async {
    final before = await _db.sumDebitCurrentMonthActive();
    final entity = TransactionEntity(
      id: _uuid.v4(),
      amount: amount,
      note: note.trim(),
      type: type,
      categoryId: categoryId,
      isSynced: false,
      isDeleted: false,
      createdAt: DateTime.now().toUtc(),
    );
    await _db.insertTransaction(entity);

    if (entity.isDebit) {
      final after = await _db.sumDebitCurrentMonthActive();
      final limit = _prefs.monthlyExpenseLimit;
      if (before <= limit && after > limit) {
        await NotificationService.showBudgetExceeded(spent: after, limit: limit);
      }
    }
  }

  Future<void> softDeleteTransaction(String id) async {
    final rows = await _db.getTransactionsWithCategory(activeOnly: false);
    TransactionWithCategory? match;
    for (final r in rows) {
      if (r.transaction.id == id) {
        match = r;
        break;
      }
    }
    if (match == null) return;
    await _db.updateTransaction(
      match.transaction.copyWith(isDeleted: true, isSynced: false),
    );
  }

  /// Full cloud sync per PDF: purge deletions, then upload unsynced rows.
  Future<void> syncWithCloud() async {
    await _purgeDeletedOnCloud();
    await _uploadUnsyncedCategories();
    await _uploadUnsyncedTransactions();
  }

  Future<void> _purgeDeletedOnCloud() async {
    final delTx = await _db.getTransactionsDeleted();
    if (delTx.isNotEmpty) {
      final ids = delTx.map((e) => e.id).toList();
      final res = await _api.deleteJson(
        '/transactions/delete/',
        body: {'ids': ids},
      );
      final deleted =
          (res['deleted_ids'] as List?)?.map((e) => e.toString()).toList() ??
              <String>[];
      for (final id in deleted) {
        await _db.hardDeleteTransaction(id);
      }
    }

    final delCat = await _db.getCategoriesDeleted();
    if (delCat.isNotEmpty) {
      final ids = delCat.map((e) => e.id).toList();
      final res = await _api.deleteJson(
        '/categories/delete/',
        body: {'ids': ids},
      );
      final deleted =
          (res['deleted_ids'] as List?)?.map((e) => e.toString()).toList() ??
              <String>[];
      for (final id in deleted) {
        await _db.hardDeleteCategory(id);
      }
    }
  }

  Future<void> _uploadUnsyncedCategories() async {
    final list = await _db.getCategoriesUnsyncedNonDeleted();
    for (final c in list) {
      final res = await _api.postJson(
        '/categories/add/',
        body: {'category_id': c.id, 'name': c.name},
      );
      final synced = (res['synced_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
      if (synced.contains(c.id) || res['status'] == 'success') {
        await _db.markCategorySynced(c.id);
      }
    }
  }

  Future<void> _uploadUnsyncedTransactions() async {
    final list = await _db.getTransactionsUnsyncedNonDeleted();
    if (list.isEmpty) return;

    final payload = list
        .map(
          (t) => {
            'id': t.id,
            'amount': t.amount,
            'note': t.note,
            'type': t.type,
            'category_id': t.categoryId,
            'timestamp': _formatApiTimestamp(t.createdAt),
          },
        )
        .toList();

    final res = await _api.postJson(
      '/transactions/add/',
      body: {'transactions': payload},
    );
    final synced =
        (res['synced_ids'] as List?)?.map((e) => e.toString()).toList() ??
            <String>[];
    for (final id in synced) {
      await _db.markTransactionSynced(id);
    }
  }

  static String _formatApiTimestamp(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
