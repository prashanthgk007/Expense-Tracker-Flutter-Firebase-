import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_expense_event.dart';
import 'add_expense_state.dart';
import '../../../Services/expense_service.dart';

class AddExpenseBloc extends Bloc<AddExpenseEvent, AddExpenseState> {
  final ExpenseService expenseService = ExpenseService();

  AddExpenseBloc() : super(AddExpenseInitial()) {
    on<SaveExpenseEvent>(_saveExpense);
  }

  Future<void> _saveExpense(
      SaveExpenseEvent event, Emitter<AddExpenseState> emit) async {
    try {
      emit(AddExpenseLoading());

      await expenseService.addExpense(event.expense);

      emit(AddExpenseSuccess());
    } catch (e) {
      emit(AddExpenseFailure(e.toString()));
    }
  }
}
