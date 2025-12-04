import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  /// -------------------- EXPENSES (Single Fetch) --------------------
  Future<List<ExpenseModel>> getExpenses() async {
    final callable = functions.httpsCallable("getExpenses");
    final response = await callable.call();

    final data = response.data as Map<String, dynamic>;
    final list = data['expenses'] as List<dynamic>;

    return list
        .map(
          (json) =>
              ExpenseModel.fromMap(Map<String, dynamic>.from(json), json['id']),
        )
        .toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final callable = functions.httpsCallable("addExpense");
    await callable.call({
      "title": expense.title,
      "amount": expense.amount,
      "category": expense.category,
      "date": expense.date.toIso8601String(),
      "notes": expense.notes,
    });
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final callable = functions.httpsCallable("updateExpense");
    await callable.call({
      "id": expense.id,
      "title": expense.title,
      "amount": expense.amount,
      "category": expense.category,
      "date": expense.date.toIso8601String(),
      "notes": expense.notes,
    });
  }

  Future<void> deleteExpense(String id) async {
    final callable = functions.httpsCallable("deleteExpense");
    await callable.call({"id": id});
  }

  /// ----------------- Budget System -----------------

  Future<Map<String, dynamic>> getBudget() async {
    final callable = FirebaseFunctions.instance.httpsCallable("getBudget");
    final result = await callable.call();

    if (result.data == null || result.data is! Map) {
      throw Exception("Invalid response from server");
    }

    return Map<String, dynamic>.from(result.data);
  }

  Future<void> updateBudget(double limit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final callable = FirebaseFunctions.instance.httpsCallable('updateBudget');

    await callable.call({"limit": limit});
  }

  /// Calculate total spent from all expenses
  Future<double> calculateTotalSpent() async {
    try {
      final expenses = await getExpenses();
      double total = 0.0;

      print("DEBUG: Calculating totalSpent from ${expenses.length} expenses");

      for (var expense in expenses) {
        print(
          "DEBUG: Expense amount: ${expense.amount}, type: ${expense.amount.runtimeType}",
        );
        total += expense.amount;
      }

      print("DEBUG: Total calculated: $total");
      return total;
    } catch (e) {
      print("ERROR: Could not calculate totalSpent: $e");
      rethrow;
    }
  }

  Future<void> setBudgetLimit(double limit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final callable = FirebaseFunctions.instance.httpsCallable("setBudgetLimit");

    await callable.call({"limit": limit});

    print("DEBUG: Budget updated using cloud function. Limit: $limit");
  }

  Future<Map<String, dynamic>> recalculateTotalSpent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final callable = FirebaseFunctions.instance.httpsCallable(
      'recalculateBudget',
    );
    final result = await callable.call();

    if (result.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(result.data);
    }

    throw Exception("Invalid response from server");
  }

  //Expense Summary / Category

  /// -------------------- EXPENSE SUMMARY (Single Fetch) --------------------
  Future<ExpenseSummary> getExpenseSummary() async {
    final callable = functions.httpsCallable("getExpenseSummary");
    final response = await callable.call();

    if (response.data == null || response.data is! Map) {
      throw Exception("Invalid summary response from server");
    }

    return ExpenseSummary.fromMap(Map<String, dynamic>.from(response.data));
  }
}
