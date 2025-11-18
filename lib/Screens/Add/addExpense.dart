import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_state.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Helper/enum.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  ExpenseCategory selectedCategory = ExpenseCategory.food;
  DateTime selectedDate = DateTime.now();

  String getCategoryDisplayName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return "Food";
      case ExpenseCategory.travel:
        return "Travel";
      case ExpenseCategory.shopping:
        return "Shopping";
      case ExpenseCategory.bills:
        return "Bills";
      case ExpenseCategory.other:
        return "Other";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: BlocConsumer<AddExpenseBloc, AddExpenseState>(
        listener: (context, state) {
          if (state is AddExpenseLoading){
AppUtils.showLoading("Adding");
          }
          if (state is AddExpenseSuccess) {
            AppUtils.showSuccess("Expense added");
            Navigator.pop(context);
          } else if (state is AddExpenseFailure) {
            AppUtils.showError(state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    const Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: "Enter expense title",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // AMOUNT
                    const Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "₹ Enter amount",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CATEGORY DROPDOWN
                    const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<ExpenseCategory>(
                        isExpanded: true,
                        value: selectedCategory,
                        underline: const SizedBox(),
                        items: ExpenseCategory.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(getCategoryDisplayName(e)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DATE PICKER
                    const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NOTES
                    const Text("Notes (optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Add extra details...",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is ExpenseLoading ? null : saveExpense,
                        child: const Text("Save Expense", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),

              if (state is ExpenseLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void saveExpense() {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

final expense = ExpenseModel(
  id: '',
  title: titleController.text.trim(),
  amount: double.tryParse(amountController.text.trim()) ?? 0.0,
  category: getCategoryDisplayName(selectedCategory),
  date: selectedDate,
  notes: notesController.text.trim(),
);

context.read<AddExpenseBloc>().add(SaveExpenseEvent(expense));
  }
}
