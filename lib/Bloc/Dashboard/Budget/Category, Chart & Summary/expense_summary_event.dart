// expense_summary_event.dart
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';

abstract class ExpenseSummaryEvent {}

class LoadExpenseSummary extends ExpenseSummaryEvent {}

class ExpenseSummaryUpdated extends ExpenseSummaryEvent {
  final ExpenseSummary summary;
  ExpenseSummaryUpdated(this.summary);
}

class ExpenseSummaryErrorEvent extends ExpenseSummaryEvent {
  final String message;
  ExpenseSummaryErrorEvent(this.message);
}