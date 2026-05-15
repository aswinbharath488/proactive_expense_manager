import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/category_entity.dart';
import '../../../data/models/transaction_with_category.dart';
import '../../../data/repositories/expense_repository.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc(this._repo) : super(const ExpenseState.initial()) {
    on<ExpenseStarted>(_onStarted);
    on<ExpenseRefreshed>(_onRefresh);
    on<ExpenseAddTransaction>(_onAddTx);
    on<ExpenseDeleteTransaction>(_onDeleteTx);
    on<ExpenseAddCategory>(_onAddCat);
    on<ExpenseDeleteCategory>(_onDeleteCat);
    on<ExpenseSyncRequested>(_onSync);
    on<ExpenseNicknameUpdated>(_onNick);
    on<ExpenseMonthlyLimitUpdated>(_onLimit);
  }

  final ExpenseRepository _repo;

  Future<void> _onStarted(ExpenseStarted event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading, initialLoad: true));
    try {
      await _repo.ensureDefaultCategories();
      await _emitFresh(emit, initialLoad: false);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
        initialLoad: false,
      ));
    }
  }

  Future<void> _onRefresh(ExpenseRefreshed event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      await _emitFresh(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _emitFresh(
    Emitter<ExpenseState> emit, {
    bool initialLoad = false,
  }) async {
    final income = await _repo.totalIncome();
    final expense = await _repo.totalExpense();
    final monthly = await _repo.monthlyDebitTotal();
    final recent = await _repo.recentTransactions(limit: 10);
    final all = await _repo.allTransactions();
    final cats = await _repo.activeCategories();
    emit(ExpenseState(
      status: ExpenseStatus.ready,
      initialLoad: initialLoad,
      errorMessage: null,
      totalIncome: income,
      totalExpense: expense,
      monthlyDebit: monthly,
      monthlyLimit: _repo.monthlyLimit,
      recent: recent,
      all: all,
      categories: cats,
      syncing: false,
    ));
  }

  Future<void> _onAddTx(
    ExpenseAddTransaction event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _repo.addTransaction(
        note: event.note,
        amount: event.amount,
        type: event.type,
        categoryId: event.categoryId,
      );
      await _emitFresh(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTx(
    ExpenseDeleteTransaction event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _repo.softDeleteTransaction(event.id);
      await _emitFresh(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCat(
    ExpenseAddCategory event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _repo.addCategory(event.name);
      await _emitFresh(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCat(
    ExpenseDeleteCategory event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _repo.softDeleteCategory(event.id);
      await _emitFresh(emit);
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSync(
    ExpenseSyncRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state.status != ExpenseStatus.ready) return;
    emit(state.copyWith(syncing: true));
    try {
      await _repo.syncWithCloud();
      await _emitFresh(emit);
    } catch (e) {
      emit(state.copyWith(
        syncing: false,
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
        preserveError: false,
      ));
    }
  }

  Future<void> _onNick(
    ExpenseNicknameUpdated event,
    Emitter<ExpenseState> emit,
  ) async {
    await _repo.updateNicknameLocal(event.nickname);
    await _emitFresh(emit);
  }

  Future<void> _onLimit(
    ExpenseMonthlyLimitUpdated event,
    Emitter<ExpenseState> emit,
  ) async {
    await _repo.setMonthlyLimit(event.limit);
    await _emitFresh(emit);
  }
}
