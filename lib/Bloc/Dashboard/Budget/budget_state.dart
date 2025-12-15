abstract class BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final Map<String, dynamic>? budget;
  BudgetLoaded(this.budget);
}

class BudgetUpdatedSuccess extends BudgetState {}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);
}
