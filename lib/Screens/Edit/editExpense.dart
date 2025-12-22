import 'package:expense_tracker_app/Bloc/Expense/Edit%20Expense/edit_expense_bloc.dart';
import 'package:expense_tracker_app/Constants/appColors.dart';
import 'package:expense_tracker_app/Helper/data.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Helper/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController notesController;

  late ExpenseCategory selectedCategory;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.expense.title);
    amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    notesController = TextEditingController(text: widget.expense.notes);

    // Convert category string to enum
    selectedCategory = Data.getCategoryValueFromList(widget.expense.category);
    selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title:  Text("Edit Expense"),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
      ),
      body: BlocConsumer<EditExpenseBloc, EditExpenseState>(
        listener: (context, state) {
          if (state is EditExpenseLoading) {
            AppUtils.showLoading("Updating...");
          } else if (state is EditExpenseSuccess) {
            AppUtils.showSuccess("Expense updated");
            Navigator.pop(context, true);
          } else if (state is EditExpenseFailure) {
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
                    const Text(
                      "Title",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),

                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: "Enter expense title",
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(color: AppColors.grey),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // AMOUNT
                    const Text(
                      "Amount",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "₹ Enter amount",
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(color: AppColors.grey),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CATEGORY DROPDOWN
                    const Text(
                      "Category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<ExpenseCategory>(
                        isExpanded: true,
                        value: selectedCategory,
                        underline: const SizedBox(),
                        dropdownColor: AppColors.white,
                        items: ExpenseCategory.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  Data.showCategoryDisplayName(e),
                                  style: const TextStyle(
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedCategory = value!);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DATE PICKER
                    const Text(
                      "Date",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                              style: const TextStyle(color: AppColors.black),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NOTES
                    const Text(
                      "Notes (optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Add extra details...",
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(color: AppColors.grey),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // UPDATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: state is EditExpenseLoading
                            ? null
                            : updateExpense,
                        child: const Text(
                          "Update",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (state is EditExpenseLoading)
                Container(
                  color: AppColors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
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

  void updateExpense() {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: AppColors.errorRed,
        ),
      );

      return;
    }

    final expense = ExpenseModel(
      id: widget.expense.id, // Keep the original ID
      title: titleController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
      category: Data.showCategoryDisplayName(selectedCategory),
      date: selectedDate,
      notes: notesController.text.trim(),
    );

    context.read<EditExpenseBloc>().add(UpdateExpenseEvent(expense));
  }
}
