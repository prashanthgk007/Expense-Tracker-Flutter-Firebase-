// expense_summary_state.dart
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';

abstract class ExpenseSummaryState {}

class ExpenseSummaryInitial extends ExpenseSummaryState {}

class ExpenseSummaryLoading extends ExpenseSummaryState {}

class ExpenseSummaryLoaded extends ExpenseSummaryState {
  final ExpenseSummary summary;
  ExpenseSummaryLoaded(this.summary);
}

class ExpenseSummaryError extends ExpenseSummaryState {
  final String message;
  ExpenseSummaryError(this.message);
}
