abstract class DeleteExpenseState {}

class DeleteExpenseInitial extends DeleteExpenseState {}

class DeleteExpenseLoading extends DeleteExpenseState {}

class DeleteExpenseSuccess extends DeleteExpenseState {}

class DeleteExpenseFailure extends DeleteExpenseState {
  final String message;
  DeleteExpenseFailure(this.message);
}
