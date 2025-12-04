import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_state.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpensesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        child: const Icon(Icons.add),
      ),

      body: MultiBlocListener(
        listeners: [
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is AddExpenseLoading) {
                AppUtils.showLoading("Loading");
              }
              if (state is ExpenseError) {
                AppUtils.showError(state.message);
              }
            },
          ),

          BlocListener<DeleteExpenseBloc, DeleteExpenseState>(
            listener: (context, state) async {
              if (state is DeleteExpenseLoading) {
                AppUtils.showLoading("Updating");
              } else if (state is DeleteExpenseSuccess) {
                AppUtils.showSuccess("Expense deleted");
              } else if (state is DeleteExpenseFailure) {
                AppUtils.showError(state.message);
              }
            },
          ),
        ],
        child: _buildExpenseList(),
      ),
    );
  }

  Widget _buildExpenseList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ExpenseLoaded) {
          final expenses = state.expenses;

          if (expenses.isEmpty) {
            return const Center(child: Text("No expenses found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP ROW — Title + Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          Text(
                            "₹${expense.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// CATEGORY + DATE ROW
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            expense.category,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 15),

                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),

                      if (expense.notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            expense.notes,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),

                      const SizedBox(height: 12),

                      /// ACTION BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                AppRoutes.editExpense,
                                arguments: expense,
                              );

                              if (result == true) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  context.read<ExpenseBloc>().add(
                                    LoadExpensesEvent(),
                                  );
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Expense"),
                                  content: const Text(
                                    "Are you sure you want to delete this item?",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: const Text("Delete"),
                                      onPressed: () {
                                        context.read<DeleteExpenseBloc>().add(
                                          DeleteExpenseRequested(expense.id),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
