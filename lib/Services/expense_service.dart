    
     import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExpense(ExpenseModel expense) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection("users").doc(uid).collection("expenses").add({
      "title": expense.title,
      "amount": expense.amount,
      "category": expense.category,
      "date": Timestamp.fromDate(expense.date),
      "notes": expense.notes ?? "",
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db
        .collection("users")
        .doc(uid)
        .collection("expenses")
        .doc(expense.id)
        .update({
      "title": expense.title,
      "amount": expense.amount,
      "category": expense.category,
      "date": Timestamp.fromDate(expense.date),
      "notes": expense.notes ?? "",
    });
  }

  Future<void> deleteExpense(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db
        .collection("users")
        .doc(uid)
        .collection("expenses")
        .doc(id)
        .delete();
  }

Future<List<ExpenseModel>> getExpenses() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final snapshot = await _db
      .collection("users")
      .doc(uid)
      .collection("expenses")
      .orderBy("createdAt", descending: true)
      .get();

  return snapshot.docs
      .map((d) => ExpenseModel.fromMap(d.data(), d.id))
      .toList();
}

}
