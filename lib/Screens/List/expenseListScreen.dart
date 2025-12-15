import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_state.dart';
import 'package:expense_tracker_app/Helper/emptyStateWidget.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Widgets/floatingActionButton.dart';
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
      floatingActionButton: CommonFAB(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addExpense),
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
            return EmptyStateWidget(
              title: "No Expenses Yet",
              description:
                  "You haven't added any expenses. Tap below to add your first expense.",
              icon: Icons.receipt_long_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE + AMOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              expense.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "₹${expense.amount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// CATEGORY + DATE
                      Row(
                        children: [
                          _infoChip(
                            icon: Icons.category_outlined,
                            text: expense.category,
                          ),
                          const SizedBox(width: 8),
                          _infoChip(
                            icon: Icons.calendar_month_outlined,
                            text:
                                "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                          ),
                        ],
                      ),

                      if (expense.notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          expense.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      /// ACTIONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.edit_outlined),
                            color: Colors.blueGrey,
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.editExpense,
                                arguments: expense,
                              );
                            },
                          ),
                          IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.redAccent,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text("Delete Expense"),
                                  content: const Text(
                                    "Are you sure you want to delete this expense?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        context.read<DeleteExpenseBloc>().add(
                                          DeleteExpenseRequested(expense.id),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Delete"),
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

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
