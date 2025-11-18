import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Services/expense_service.dart';
import '../../../Model/expenseModel.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseService expenseService = ExpenseService();

  ExpenseBloc() : super(ExpenseInitial()) {
    on<LoadExpensesEvent>(_loadExpenses);
  }

  Future<void> _loadExpenses(
      LoadExpensesEvent event, Emitter<ExpenseState> emit) async {
    try {
      emit(ExpenseLoading());

      final expenses = await expenseService.getExpenses();
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
