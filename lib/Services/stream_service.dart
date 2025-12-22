import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';

class ExpenseStreamService {
  static final ExpenseStreamService _instance = ExpenseStreamService._internal();
  factory ExpenseStreamService() => _instance;
  ExpenseStreamService._internal();

  final ExpenseService _repo = ExpenseService();
  bool _isClosed = false;

  /// Call this when the app is closing or disposal is needed
  void dispose() {
    _isClosed = true;
  }

  /// Restart streams if they were previously closed
  void reset() {
    _isClosed = false;
  }

  /// Stream expenses with polling
  Stream<List<ExpenseModel>> streamExpenses({
    Duration interval = const Duration(milliseconds: 1),
  }) async* {
    while (!_isClosed) {
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
    Duration interval = const Duration(milliseconds: 1),
  }) async* {
    while (!_isClosed) {
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
    Duration interval = const Duration(milliseconds: 1),
  }) async* {
    while (!_isClosed) {
      try {
        yield await _repo.getExpenseSummary();
      } catch (e) {
        yield ExpenseSummary.empty();
      }
      await Future.delayed(interval);
    }
  }
}
