abstract class BudgetEvent {}

class LoadBudget extends BudgetEvent {}

class RefreshBudget extends BudgetEvent {}

// Internal events for real-time stream updates
class BudgetUpdatedEvent extends BudgetEvent {
  final Map<String, dynamic>? data;
  BudgetUpdatedEvent(this.data);
}

class BudgetErrorEvent extends BudgetEvent {
  final String message;
  BudgetErrorEvent(this.message);
}