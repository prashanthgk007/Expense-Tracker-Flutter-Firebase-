// -------------------------------------------
// HOME DASHBOARD
// -------------------------------------------
import 'package:expense_tracker_app/Bloc/Budget/budget_bloc.dart';
import 'package:expense_tracker_app/Bloc/Budget/budget_event.dart';
import 'package:expense_tracker_app/Bloc/Budget/budget_state.dart';
import 'package:expense_tracker_app/Helper/enum.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Screens/Charts/dashboardCharts.dart';
import 'package:expense_tracker_app/Services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ChartType selectedChart = ChartType.pie;

  final List<String> chartOptions = ["Pie", "Bar", "Area"];

  @override
  void initState() {
    super.initState();
    // context.read<BudgetBloc>().add(LoadBudget());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.setting),
          ),
        ],
      ),

      // FLOATING BUTTON (optional)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addExpense),
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------
            // 4. CHART SECTION - DAILY / WEEKLY / MONTHLY
            // -------------------------------------------
            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // -------------------------------------------------------
            // 🔥 PASS VALUE TO CHART WIDGET
            // -------------------------------------------------------
            DashboardCharts(),
            const SizedBox(height: 25),
            // -------------------------------------------
            // 1. SUMMARY CARDS
            // -------------------------------------------
            const Text(
              "Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _summaryCard("Total Spent", "₹12,500", Icons.wallet),
                const SizedBox(width: 12),
                _summaryCard("This Month", "₹4,200", Icons.calendar_today),
              ],
            ),

            const SizedBox(height: 25),

            // -------------------------------------------
            // 2. CATEGORY BREAKDOWN
            // -------------------------------------------
            const Text(
              "Category Breakdown",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _categoryBreakdown(),

            // const SizedBox(height: 25),

            // // -------------------------------------------
            // // 3. RECENT TRANSACTIONS
            // // -------------------------------------------
            // const Text(
            //   "Recent Transactions",
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),

            // const SizedBox(height: 10),

            // _recentTransaction("Food", "₹250", "Today"),
            // _recentTransaction("Travel", "₹1200", "Yesterday"),
            // _recentTransaction("Shopping", "₹1800", "2 days ago"),
            const SizedBox(height: 25),

            // -------------------------------------------
            // 5. BUDGET TRACKING
            // -------------------------------------------
            const Text(
              "Budget Tracking",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BudgetError) {
                  return Text(
                    "Error: ${state.message}",
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (state is BudgetLoaded && state.budget != null) {
                  final budget = state.budget!;
                  final double limit = (budget["limit"] ?? 0).toDouble();
                  final double spent = (budget["totalSpent"] ?? 0).toDouble();
                  final double percent = limit > 0 ? spent / limit : 0;

                  return _budgetCard(limit, spent, percent);
                }

                return GestureDetector(
                  onTap: () => _showSetBudgetDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "No budget set yet",
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showSetBudgetDialog(context),
                          tooltip: "Set Budget",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // SUB WIDGETS
  // -----------------------------

  Widget _summaryCard(String title, String amount, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBreakdown() {
    return Column(
      children: [
        _categoryTile("Food", "₹2500", 0.40),
        _categoryTile("Travel", "₹1200", 0.20),
        _categoryTile("Shopping", "₹1800", 0.25),
        _categoryTile("Bills", "₹1000", 0.15),
      ],
    );
  }

  Widget _categoryTile(String title, String amount, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 10),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _recentTransaction(String title, String amount, String time) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _chartView() {
    if (selectedChart == "Daily") {
      return _dailyChart();
    } else if (selectedChart == "Weekly") {
      return _weeklyChart();
    } else {
      return _monthlyChart();
    }
  }

  Widget _dailyChart() {
    return _chartBox("Daily Chart Placeholder");
  }

  Widget _weeklyChart() {
    return _chartBox("Weekly Chart Placeholder");
  }

  Widget _monthlyChart() {
    return _chartBox("Monthly Chart Placeholder");
  }

  Widget _chartBox(String label) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 16))),
    );
  }

  Widget _budgetCard(double limit, double spent, double percent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Budget: ₹$limit",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () async {
                      try {
                        AppUtils.showLoading("Recalculating...");
                        final expenseService = ExpenseService();
                        await expenseService.recalculateTotalSpent();

                        // Wait for update
                        await Future.delayed(const Duration(milliseconds: 300));

                        // Reload budget
                        if (context.mounted) {
                          context.read<BudgetBloc>().add(LoadBudget());
                        }

                        AppUtils.showSuccess("Budget recalculated!");
                      } catch (e) {
                        AppUtils.showError(
                          "Failed to recalculate: ${e.toString()}",
                        );
                      }
                    },
                    tooltip: "Recalculate Spent",
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () =>
                        _showSetBudgetDialog(context, currentLimit: limit),
                    tooltip: "Edit Budget",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade300,
          ),

          const SizedBox(height: 10),

          Text(
            "₹${spent.toStringAsFixed(2)} spent • ${(percent * 100).toStringAsFixed(1)}% used",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, {double? currentLimit}) {
    final TextEditingController budgetController = TextEditingController(
      text: currentLimit != null && currentLimit > 0
          ? currentLimit.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          currentLimit != null && currentLimit > 0
              ? "Edit Budget"
              : "Set Monthly Budget",
        ),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Budget Amount (₹)",
            hintText: "Enter monthly budget",
            border: OutlineInputBorder(),
            prefixText: "₹ ",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountText = budgetController.text.trim();
              if (amountText.isEmpty) {
                AppUtils.showError("Please enter a budget amount");
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                AppUtils.showError("Please enter a valid budget amount");
                return;
              }

              Navigator.pop(dialogContext);

              try {
                AppUtils.showLoading("Setting budget...");
                final expenseService = ExpenseService();

                // Calculate and set budget
                await expenseService.setBudgetLimit(amount);

                // Wait a moment for Firestore to update
                await Future.delayed(const Duration(milliseconds: 500));

                // Reload budget
                if (context.mounted) {
                  context.read<BudgetBloc>().add(LoadBudget());
                }

                AppUtils.showSuccess("Budget set successfully!");
              } catch (e) {
                final errorMessage = e.toString().toLowerCase();
                String userMessage;

                if (errorMessage.contains('permission-denied') ||
                    errorMessage.contains('missing or insufficient')) {
                  userMessage =
                      "Permission denied. Please make sure you're logged in and try again.";
                } else {
                  userMessage = "Failed to set budget: ${e.toString()}";
                  print("ERROR setting budget: $e");
                }

                AppUtils.showError(userMessage);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
