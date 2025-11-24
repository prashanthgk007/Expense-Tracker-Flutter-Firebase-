import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../Services/expense_service.dart';
import '../../../Model/expenseModel.dart';

part 'edit_expense_event.dart';
part 'edit_expense_state.dart';

class EditExpenseBloc extends Bloc<EditExpenseEvent, EditExpenseState> {
  final ExpenseService expenseService = ExpenseService();

  EditExpenseBloc() : super(EditExpenseInitial()) {
    on<UpdateExpenseEvent>(_updateExpense);
  }

  Future<void> _updateExpense(
      UpdateExpenseEvent event, Emitter<EditExpenseState> emit) async {
    try {
      emit(EditExpenseLoading());

      await expenseService.updateExpense(event.expense);

      emit(EditExpenseSuccess());
    } catch (e) {
      emit(EditExpenseFailure(e.toString()));
    }
  }
}
