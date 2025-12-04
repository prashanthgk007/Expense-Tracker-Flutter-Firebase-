abstract class ExpenseEvent {}

class LoadExpensesEvent extends ExpenseEvent {}

class ExpensesUpdatedEvent extends ExpenseEvent {
  final List expenses;
  ExpensesUpdatedEvent(this.expenses);
}

class ExpensesErrorEvent extends ExpenseEvent {
  final String message;
  ExpensesErrorEvent(this.message);
}
