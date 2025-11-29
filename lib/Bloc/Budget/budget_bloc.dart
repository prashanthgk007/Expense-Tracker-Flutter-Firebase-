import 'dart:async';
import 'package:expense_tracker_app/Bloc/Budget/budget_event.dart';
import 'package:expense_tracker_app/Bloc/Budget/budget_state.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final ExpenseService _service = ExpenseService();
  StreamSubscription? _subscription;

  BudgetBloc() : super(BudgetLoading()) {
    // Register event handlers once in constructor
    on<LoadBudget>(_onLoadBudget);
    on<RefreshBudget>(_onRefreshBudget);
    on<BudgetUpdatedEvent>(_onBudgetUpdated);
    on<BudgetErrorEvent>(_onBudgetError);
  }

  void _onLoadBudget(LoadBudget event, Emitter<BudgetState> emit) {
    _startRealTimeStream();
  }

  void _onRefreshBudget(RefreshBudget event, Emitter<BudgetState> emit) {
    // Cancel existing subscription and restart
    _subscription?.cancel();
    _startRealTimeStream();
  }

  void _onBudgetUpdated(BudgetUpdatedEvent event, Emitter<BudgetState> emit) {
    emit(BudgetLoaded(event.data));
  }

  void _onBudgetError(BudgetErrorEvent event, Emitter<BudgetState> emit) {
    emit(BudgetError(event.message));
  }

  void _startRealTimeStream() {
    // Cancel any existing subscription first
    _subscription?.cancel();

    try {
      // Start real-time stream - Firestore snapshots() provides automatic updates
      // This stream listens continuously and emits on every document change
      // It will emit immediately with current data, then on every change
      _subscription = _service.getBudget().listen(
        (data) {
          // Emit new state whenever budget data changes
          // This triggers automatically when:
          // - Expense is added (Cloud Function updates budget)
          // - Expense is updated (Cloud Function updates budget) 
          // - Expense is deleted (Cloud Function updates budget)
          // - Budget limit is changed manually
          add(BudgetUpdatedEvent(data));
        },
        onError: (e) {
          final errorMessage = e.toString().toLowerCase();
          if (errorMessage.contains('permission-denied') || 
              errorMessage.contains('missing or insufficient')) {
            add(BudgetUpdatedEvent(null));
          } else {
            add(BudgetErrorEvent(e.toString()));
          }
        },
        cancelOnError: false, // Keep listening even after errors
      );
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('permission-denied') || 
          errorMessage.contains('missing or insufficient')) {
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


