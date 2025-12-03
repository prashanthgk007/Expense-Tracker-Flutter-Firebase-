// expense_summary_bloc.dart
import 'package:expense_tracker_app/Services/expense_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_summary_event.dart';
import 'expense_summary_state.dart';

class ExpenseSummaryBloc extends Bloc<ExpenseSummaryEvent, ExpenseSummaryState> {
  final ExpenseService expenseService = ExpenseService();

  ExpenseSummaryBloc()
      : super(ExpenseSummaryInitial()) {
    on<LoadExpenseSummary>(_loadSummary);
  }

  Future<void> _loadSummary(
      LoadExpenseSummary event, Emitter<ExpenseSummaryState> emit) async {
    try {
      emit(ExpenseSummaryLoading());

      final summary = await expenseService.getExpenseSummary();

      emit(ExpenseSummaryLoaded(summary));
    } catch (e) {
      emit(ExpenseSummaryError(e.toString()));
    }
  }
}
