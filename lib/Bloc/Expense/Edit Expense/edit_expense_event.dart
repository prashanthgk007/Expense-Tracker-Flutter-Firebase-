part of 'edit_expense_bloc.dart';

sealed class EditExpenseEvent extends Equatable {
  const EditExpenseEvent();

  @override
  List<Object> get props => [];
}

class UpdateExpenseEvent extends EditExpenseEvent {
  final ExpenseModel expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object> get props => [expense];
}
