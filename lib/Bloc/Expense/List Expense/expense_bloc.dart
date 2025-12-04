import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Services/stream_service.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseStreamService _streams = ExpenseStreamService();
  StreamSubscription? _subscription;

  ExpenseBloc() : super(ExpenseInitial()) {
    on<LoadExpensesEvent>(_onLoad);
    on<ExpensesUpdatedEvent>(_onExpensesUpdated);
    on<ExpensesErrorEvent>(_onError);
  }

  void _onLoad(LoadExpensesEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseLoading());
    _subscription?.cancel();

    _subscription = _streams.streamExpenses().listen(
      (expenses) {
        add(ExpensesUpdatedEvent(expenses));
      },
      onError: (e) {
        add(ExpensesErrorEvent(e.toString()));
      },
    );
  }

  void _onExpensesUpdated(
      ExpensesUpdatedEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseLoaded(event.expenses));
  }

  void _onError(
      ExpensesErrorEvent event, Emitter<ExpenseState> emit) {
    emit(ExpenseError(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
