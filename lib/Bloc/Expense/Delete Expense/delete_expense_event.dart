abstract class DeleteExpenseEvent {}

class DeleteExpenseRequested extends DeleteExpenseEvent {
  final String id;
  DeleteExpenseRequested(this.id);
}
