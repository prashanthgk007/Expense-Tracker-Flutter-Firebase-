import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Model/expenseSummaryModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseStreamService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  /// Stream expenses (Real-time from Firestore)
  Stream<List<ExpenseModel>> streamExpenses() {
    try {
      return _db
          .collection("users")
          .doc(_uid)
          .collection("expenses")
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data(); 
          // Handle Timestamp conversion
          if (data['date'] is Timestamp) {
            data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
          }
          return ExpenseModel.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      print("STREAM ERROR (Expenses): $e");
      return Stream.value([]);
    }
  }

  /// Stream budget (Real-time)
  Stream<Map<String, dynamic>> streamBudget() {
    try {
      return _db
          .collection("users")
          .doc(_uid)
          .collection("budget")
          .doc("budget")
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          return doc.data() as Map<String, dynamic>;
        } else {
          return {"limit": 0, "totalSpent": 0, "updatedAt": null};
        }
      });
    } catch (e) {
      return Stream.value({"error": e.toString()});
    }
  }

  /// Stream Summary (Derived from Expenses Stream)
  Stream<ExpenseSummary> streamExpenseSummary() {
    return streamExpenses().map((expenses) {
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

      return ExpenseSummary(
        totalSpent: totalSpent,
        thisMonthSpent: thisMonthSpent,
        categories: categoryTotals,
      );
    });
  }
}
