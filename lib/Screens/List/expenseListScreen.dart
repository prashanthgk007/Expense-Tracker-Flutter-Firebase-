import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_state.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late DeleteExpenseBloc deleteExpenseBloc;

  @override
  void initState() {
    super.initState();
    deleteExpenseBloc = DeleteExpenseBloc();
    context.read<ExpenseBloc>().add(LoadExpensesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        child: const Icon(Icons.add),
      ),

      body: MultiBlocListener(
        listeners: [
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),

          BlocListener<DeleteExpenseBloc, DeleteExpenseState>(
            bloc: deleteExpenseBloc,
            listener: (context, state) {
              if (state is DeleteExpenseLoading) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Deleting...")));
              } else if (state is DeleteExpenseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Expense deleted successfully")),
                );

                /// Refresh the list
                context.read<ExpenseBloc>().add(LoadExpensesEvent());
              } else if (state is DeleteExpenseFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed: ${state.message}")),
                );
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
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return ListTile(
                leading: const Icon(Icons.money),
                title: Text(expense.title),
                subtitle: Text(
                  "${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editExpense,
                          arguments: expense,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
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
                                  deleteExpenseBloc.add(
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
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
