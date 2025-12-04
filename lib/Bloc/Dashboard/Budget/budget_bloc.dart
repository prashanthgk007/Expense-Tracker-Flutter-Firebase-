import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Services/expense_service.dart';
import '../../../Services/stream_service.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final ExpenseService _service = ExpenseService();
  final ExpenseStreamService _streams = ExpenseStreamService();

  StreamSubscription? _subscription;

  BudgetBloc() : super(BudgetLoading()) {
    on<LoadBudget>(_onLoad);
    on<BudgetUpdatedEvent>(_onBudgetUpdated);
    on<BudgetErrorEvent>(_onError);

    // Actions
    on<SetBudgetLimit>(_onSetLimit);
    on<RecalculateBudget>(_onRecalculate);
  }

  // ---------------- LOAD STREAM ----------------

  void _onLoad(LoadBudget event, Emitter<BudgetState> emit) {
    emit(BudgetLoading());
    _subscription?.cancel();

    _subscription = _streams.streamBudget().listen(
      (data) {
        add(BudgetUpdatedEvent(data));
      },
      onError: (e) {
        add(BudgetErrorEvent(e.toString()));
      },
    );
  }

  // ---------------- STREAM STATE HANDLERS ----------------

  void _onBudgetUpdated(
      BudgetUpdatedEvent event, Emitter<BudgetState> emit) {
    emit(BudgetLoaded(event.data));
  }

  void _onError(BudgetErrorEvent event, Emitter<BudgetState> emit) {
    emit(BudgetError(event.message));
  }

  // ---------------- ACTION HANDLERS ----------------

  Future<void> _onSetLimit(
      SetBudgetLimit event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());

    try {
      await _service.setBudgetLimit(event.limit);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onRecalculate(
      RecalculateBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());

    try {
      await _service.recalculateTotalSpent();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
