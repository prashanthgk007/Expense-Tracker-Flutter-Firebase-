import 'package:bloc/bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_state.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';

class DeleteExpenseBloc extends Bloc<DeleteExpenseEvent, DeleteExpenseState> {
  final ExpenseService _service = ExpenseService();

  DeleteExpenseBloc() : super(DeleteExpenseInitial()) {
    on<DeleteExpenseRequested>((event, emit) async {
      emit(DeleteExpenseLoading());

      try {
        await _service.deleteExpense(event.id);
        emit(DeleteExpenseSuccess());
      } catch (e) {
        emit(DeleteExpenseFailure(AppUtils.extractErrorMessage(e)));
      }
    });
  }
}
