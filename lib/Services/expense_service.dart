import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final FirebaseFunctions functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<ExpenseModel>> getExpenses() async {
    final callable = functions.httpsCallable("getExpenses");

    final result = await callable.call();
    final data = result.data as Map<String, dynamic>;
    final expensesList = data['expenses'] as List<dynamic>;

    return expensesList
        .map((e) => ExpenseModel.fromMap(Map<String, dynamic>.from(e), e['id']))
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

  Stream<Map<String, dynamic>?> getBudget() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not logged in");
    }

    return _firestore
        .collection("users")
        .doc(userId)
        .collection("budget")
        .doc("budget") // one document only
        .snapshots()
        .map((snapshot) {
          // Ensure we always return data (null if document doesn't exist)
          return snapshot.data();
        })
        .handleError((error) {
          // Handle any stream errors
          throw Exception("Failed to load budget: $error");
        });
  }

  Future<void> updateBudget({
    required double limit,
    required double totalSpent,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not logged in");
    }

    await _firestore
        .collection("users")
        .doc(userId)
        .collection("budget")
        .doc("budget")
        .set({
          "limit": limit,
          "totalSpent": totalSpent,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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

  /// Set budget limit and calculate totalSpent from existing expenses
  Future<void> setBudgetLimit(double limit) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;

    // Calculate total spent from all expenses
    double totalSpent = 0.0;
    try {
      totalSpent = await calculateTotalSpent();
      print(
        "DEBUG: Setting budget with limit: $limit, totalSpent: $totalSpent",
      );
    } catch (e) {
      print("Warning: Could not fetch expenses to calculate totalSpent: $e");
      // If we can't fetch expenses, try to get existing totalSpent from budget
      final budgetRef = _firestore
          .collection("users")
          .doc(userId)
          .collection("budget")
          .doc("budget");
      try {
        final budgetDoc = await budgetRef.get();
        if (budgetDoc.exists) {
          final budgetData = budgetDoc.data();
          totalSpent = budgetData?["totalSpent"] != null
              ? (budgetData!["totalSpent"] as num).toDouble()
              : 0.0;
          print("DEBUG: Using existing totalSpent from budget: $totalSpent");
        }
      } catch (error) {
        print("ERROR: Could not get existing totalSpent: $error");
        // Use 0 if we can't get existing value
        totalSpent = 0.0;
      }
    }

    final budgetRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("budget")
        .doc("budget");

    // Use set with merge to create or update
    await budgetRef.set({
      "limit": limit,
      "totalSpent": totalSpent,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print(
      "DEBUG: Budget updated successfully with limit: $limit, totalSpent: $totalSpent",
    );
  }

  /// Recalculate and update totalSpent from expenses
  Future<void> recalculateTotalSpent() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;
    final totalSpent = await calculateTotalSpent();

    final budgetRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("budget")
        .doc("budget");

    // Get existing limit to preserve it
    final budgetDoc = await budgetRef.get();
    final existingLimit = budgetDoc.exists
        ? (budgetDoc.data()?["limit"] ?? 0.0).toDouble()
        : 0.0;

    await budgetRef.set({
      "limit": existingLimit,
      "totalSpent": totalSpent,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<ExpenseSummary> getExpenseSummary() async {
    final callable = functions.httpsCallable("getExpenseSummary");

    final result = await callable.call();

    if (result.data == null || result.data is! Map) {
      throw Exception("Invalid summary response from server");
    }

    final data = Map<String, dynamic>.from(result.data);

    return ExpenseSummary.fromMap(data);
  }
}
