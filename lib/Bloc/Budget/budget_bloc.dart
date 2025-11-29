import 'dart:async';
import 'package:expense_tracker_app/Bloc/Budget/budget_event.dart';
import 'package:expense_tracker_app/Bloc/Budget/budget_state.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:expense_tracker_app/Bloc/Budget/budget_event.dart';
import 'package:expense_tracker_app/Bloc/Budget/budget_state.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final ExpenseService _service = ExpenseService();
  StreamSubscription? _subscription;

  BudgetBloc() : super(BudgetLoading()) {
    // Existing event handlers
    on<LoadBudget>(_onLoadBudget);
    on<RefreshBudget>(_onRefreshBudget);
    on<BudgetUpdatedEvent>(_onBudgetUpdated);
    on<BudgetErrorEvent>(_onBudgetError);

    // *** NEW EVENTS ADDED HERE ***
    on<SetBudgetLimit>(_onSetBudgetLimit);
    on<RecalculateBudget>(_onRecalculateBudget);
  }

  // ---- EVENT HANDLERS ----

  void _onLoadBudget(LoadBudget event, Emitter<BudgetState> emit) {
    _startRealTimeStream();
  }

  void _onRefreshBudget(RefreshBudget event, Emitter<BudgetState> emit) {
    _subscription?.cancel();
    _startRealTimeStream();
  }

  void _onBudgetUpdated(BudgetUpdatedEvent event, Emitter<BudgetState> emit) {
    emit(BudgetLoaded(event.data));
  }

  void _onBudgetError(BudgetErrorEvent event, Emitter<BudgetState> emit) {
    emit(BudgetError(event.message));
  }

  /// 👉 NEW HANDLER: Set Budget Limit
  Future<void> _onSetBudgetLimit(
      SetBudgetLimit event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await _service.setBudgetLimit(event.limit);
      add(LoadBudget()); // refresh UI
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  /// 👉 NEW HANDLER: Recalculate Budget
  Future<void> _onRecalculateBudget(
      RecalculateBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await _service.recalculateTotalSpent();
      add(LoadBudget()); // refresh UI
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  // ---- REALTIME LISTENER ----

  void _startRealTimeStream() {
    _subscription?.cancel();

    try {
      _subscription = _service.getBudget().listen(
        (data) {
          add(BudgetUpdatedEvent(data));
        },
        onError: (e) {
          final msg = e.toString().toLowerCase();
          if (msg.contains('permission-denied') ||
              msg.contains('missing or insufficient')) {
            add(BudgetUpdatedEvent(null));
          } else {
            add(BudgetErrorEvent(e.toString()));
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('permission-denied') ||
          msg.contains('missing or insufficient')) {
        add(BudgetUpdatedEvent(null));
      } else {
        add(BudgetErrorEvent(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
