import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';

class ExpenseStreamService {
  final ExpenseService _repo = ExpenseService();

  /// Stream expenses with polling
  Stream<List<ExpenseModel>> streamExpenses({
    Duration interval = const Duration(seconds: 8),
  }) async* {
    while (true) {
      try {
        yield await _repo.getExpenses();
      } catch (e) {
        print("STREAM ERROR (Expenses): $e");
        yield [];
      }
      await Future.delayed(interval);
    }
  }

  /// Stream budget with polling
  Stream<Map<String, dynamic>> streamBudget({
    Duration interval = const Duration(seconds: 10),
  }) async* {
    while (true) {
      try {
        yield await _repo.getBudget();
      } catch (e) {
        yield {"error": e.toString()};
      }
      await Future.delayed(interval);
    }
  }

  /// Stream Summary
  Stream<ExpenseSummary> streamExpenseSummary({
    Duration interval = const Duration(seconds: 8),
  }) async* {
    while (true) {
      try {
        yield await _repo.getExpenseSummary();
      } catch (e) {
        yield ExpenseSummary.empty();
      }
      await Future.delayed(interval);
    }
  }
}
