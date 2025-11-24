import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_event.dart';

class DeleteExpenseBloc extends Bloc<DeleteExpenseEvent, DeleteExpenseState> {
  DeleteExpenseBloc() : super(DeleteExpenseInitial()) {
    on<DeleteExpenseRequested>((event, emit) async {
      emit(DeleteExpenseLoading());

      try {
        final callable = FirebaseFunctions.instance.httpsCallable('deleteExpense');
        await callable.call({"id": event.id});

        emit(DeleteExpenseSuccess());
      } catch (e) {
        emit(DeleteExpenseFailure(e.toString()));
      }
    });
  }
}
