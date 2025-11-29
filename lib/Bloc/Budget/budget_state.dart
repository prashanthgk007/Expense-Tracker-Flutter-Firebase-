abstract class BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final Map<String, dynamic>? budget;
  BudgetLoaded(this.budget);
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);
}
