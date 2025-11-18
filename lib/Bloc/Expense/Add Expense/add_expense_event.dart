import 'package:equatable/equatable.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';

abstract class AddExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveExpenseEvent extends AddExpenseEvent {
  final ExpenseModel expense;

  SaveExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}
