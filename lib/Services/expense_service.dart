import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
class ExpenseService {
  final FirebaseFunctions functions = FirebaseFunctions.instance;

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
}
