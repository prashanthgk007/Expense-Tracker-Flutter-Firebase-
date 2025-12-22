import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  CollectionReference get _expensesRef =>
      _db.collection("users").doc(_uid).collection("expenses");

  DocumentReference get _budgetRef =>
      _db.collection("users").doc(_uid).collection("budget").doc("budget");

  /// -------------------- EXPENSES (Single Fetch) --------------------
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final snapshot = await _expensesRef
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Handle Timestamp conversion if necessary, though helper methods inside Model might handle it.
        // Assuming Model expects Map. Need to ensure 'date' is handled.
        // The cloud function returned ISO string for date. Firestore returns Timestamp.
        // We might need to adjust map content or rely on Model.
        // Let's check ExpenseModel.
        return _mapDocToModel(doc);
      }).toList();
    } catch (e) {
      print("Error fetching expenses: $e");
      rethrow;
    }
  }

  ExpenseModel _mapDocToModel(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Convert Firestore Timestamp to whatever Model expects if needed.
    // If Model expects String date (ISO), we convert.
    // However, looking at previous code: `date: data.date.toDate().toISOString()` was done in cloud function.
    // So Model likely expects 'date' (String) or checks type.
    // Let's be safe and convert Timestamp to ISO string if it is Timestamp.
    if (data['date'] is Timestamp) {
      data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
    }
    return ExpenseModel.fromMap(data, doc.id);
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesRef.add({
      "title": expense.title,
      "amount": expense.amount,
      "category": expense.category,
      "date": Timestamp.fromDate(expense.date), // Store as Timestamp
      "notes": expense.notes,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expensesRef.doc(expense.id).update({
      "title": expense.title,
      "amount": expense.amount,
      "category": expense.category,
      "date": Timestamp.fromDate(expense.date),
      "notes": expense.notes,
    });
  }

  Future<void> deleteExpense(String id) async {
    await _expensesRef.doc(id).delete();
  }

  /// ----------------- Budget System -----------------

  Future<Map<String, dynamic>> getBudget() async {
    final doc = await _budgetRef.get();

    if (doc.exists && doc.data() != null) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return {
        "limit": 0,
        "totalSpent": 0,
        "updatedAt": null,
      };
    }
  }

  Future<void> updateBudget(double limit) async {
    // We only update the limit. totalSpent should be calculated or preserved.
    // Since we are moving logic to client, we can just setMerge.
    await _budgetRef.set({
      "limit": limit,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<double> calculateTotalSpent() async {
    // Client side calculation
    try {
      final expenses = await getExpenses();
      double total = 0.0;
      for (var expense in expenses) {
        total += expense.amount;
      }
      return total;
    } catch (e) {
      print("ERROR: Could not calculate totalSpent: $e");
      rethrow;
    }
  }

  Future<void> setBudgetLimit(double limit) async {
    await updateBudget(limit);
  }

  /// -------------------- EXPENSE SUMMARY (Single Fetch) --------------------
  /// Calculated Client-Side now to support Offline
  Future<ExpenseSummary> getExpenseSummary() async {
    try {
      final expenses = await getExpenses();

      double totalSpent = 0;
      double thisMonthSpent = 0;
      Map<String, double> categoryTotals = {};
      
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      for (var e in expenses) {
        totalSpent += e.amount;
        
        if (e.date.isAfter(startOfMonth) || e.date.isAtSameMomentAs(startOfMonth)) {
          thisMonthSpent += e.amount;
        }

        final cat = e.category.isEmpty ? "Other" : e.category;
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + e.amount;
      }

      // Construct ExpenseSummary manually since fromMap expected cloud function response
      // We can use a constructor or create a map that matches fromMap structure.
      // Let's assume ExpenseSummary has a constructor or factory we can use or mock the map.
      
      return ExpenseSummary(
        totalSpent: totalSpent,
        thisMonthSpent: thisMonthSpent,
        categories: categoryTotals,
      );

    } catch (e) {
      print("Error generating summary: $e");
      // Return empty summary on error or rethrow
      return ExpenseSummary.empty();
    }
  }
}
