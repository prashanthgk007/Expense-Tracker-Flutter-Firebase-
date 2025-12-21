// ---------------------------------------------------------
// MODERN DASHBOARD UI
// ---------------------------------------------------------
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_bloc.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_event.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_state.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/Category,%20Chart%20&%20Summary/expense_summary_bloc.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/Category,%20Chart%20&%20Summary/expense_summary_state.dart';
import 'package:expense_tracker_app/Constants/appColors.dart';
import 'package:expense_tracker_app/Helper/data.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Widgets/floatingActionButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      floatingActionButton: CommonFAB(
        heroTag: 'dashboard_fab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addExpense),
      ),

      body: MultiBlocListener(
        listeners: [
          BlocListener<BudgetBloc, BudgetState>(
            listener: (context, state) {
              // if (state is BudgetLoading) AppUtils.showLoading("Updating...");
              if (state is BudgetLoaded) {
                AppUtils.dismiss();
              }
              if (state is BudgetError) {
                AppUtils.dismiss();
                AppUtils.showError(state.message);
              }
            },
          ),
        ],

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Monthly Budget"),
              const SizedBox(height: 12),

              BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  // 🔄 Loading / Updating
                  if (state is BudgetLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // ✅ Budget Loaded
                  if (state is BudgetLoaded) {
                    if (state.budget != null) {
                      final limit = AppUtils.toDouble(state.budget!["limit"]);
                      final spent = AppUtils.toDouble(
                        state.budget!["totalSpent"],
                      );
                      final double percent = limit > 0 ? (spent / limit) : 0.0;

                      return _modernBudgetCard(limit, spent, percent);
                    }

                    // ❗ No budget set
                    return _noBudgetBox(context);
                  }

                  // ❌ Error or initial fallback
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 30),

              _sectionTitle("Summary"),
              const SizedBox(height: 14),

              BlocBuilder<ExpenseSummaryBloc, ExpenseSummaryState>(
                builder: (context, state) {
                  if (state is ExpenseSummaryLoaded) {
                    return Row(
                      children: [
                        _summaryCard(
                          title: "Total Spent",
                          amount:
                              "₹${AppUtils.toDouble(state.summary.totalSpent)}",

                          icon: Icons.account_balance_wallet_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: "This Month",
                          amount: "₹${state.summary.thisMonthSpent}",
                          icon: Icons.calendar_month_outlined,
                          color: Colors.purple,
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              const SizedBox(height: 30),

              _sectionTitle("Category Breakdown"),
              const SizedBox(height: 12),

              BlocBuilder<ExpenseSummaryBloc, ExpenseSummaryState>(
                builder: (context, state) {
                  if (state is ExpenseSummaryLoaded) {
                    final summary = state.summary;
                    final total = summary.totalSpent;

                    // 🔹 Create a normalized map (all categories with default 0)
                    final Map<String, double> normalizedCategories = {
                      for (var cat in Data.allCategories) cat: 0.0,
                    };

                    // 🔹 Override with actual data from Firestore
                    summary.categories.forEach((key, value) {
                      normalizedCategories[key] = AppUtils.toDouble(value);
                    });

                    return Column(
                      children: normalizedCategories.entries.map((entry) {
                        final percent = total > 0 ? entry.value / total : 0.0;

                        return _modernCategoryTile(
                          entry.key,
                          entry.value,
                          percent,
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox();
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // UI COMPONENTS
  // ---------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: AppColors.shadow,
              offset: Offset(1, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernCategoryTile(String title, double amount, double percent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(1, 2),
            color: AppColors.shadow,
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: AppColors.grey300,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primaryAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text("₹$amount", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _modernBudgetCard(double limit, double spent, double percent) {
    // 🎨 Dynamic colors based on usage
    Color startColor;
    Color endColor;

    if (percent < 0.5) {
      startColor = AppColors.success.withOpacity(0.85);
      endColor = AppColors.success.withOpacity(0.65);
    } else if (percent < 0.8) {
      startColor = AppColors.warning.withOpacity(0.85);
      endColor = AppColors.warning.withOpacity(0.65);
    } else {
      startColor = AppColors.error.withOpacity(0.85);
      endColor = AppColors.error.withOpacity(0.65);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: startColor.withOpacity(0.4),
            offset: const Offset(1, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Budget Overview",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => _showEditBudgetDialog(context, limit),
                child: Icon(Icons.edit, color: AppColors.white),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
            ),
          ),

          const SizedBox(height: 12),

          /// TEXT
          Text(
            "₹${spent.toStringAsFixed(0)} spent of ₹${limit.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          /// STATUS LABEL (optional but professional)
          Text(
            percent >= 1
                ? "Budget exceeded"
                : percent >= 0.8
                ? "Approaching limit"
                : "Within budget",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Widget _circleActionButton({
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       margin: const EdgeInsets.only(right: 15),
  //       padding: const EdgeInsets.all(8),
  //       decoration: const BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: Colors.black12,
  //       ),
  //       child: Icon(icon, color: Colors.black),
  //     ),
  //   );
  // }

  Widget _noBudgetBox(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditBudgetDialog(context, null),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey300),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("No budget set yet", style: TextStyle(fontSize: 16)),
            Icon(Icons.add),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // BUDGET POPUP
  // ---------------------------------------------------------

  void _showEditBudgetDialog(BuildContext context, double? existingLimit) {
    final controller = TextEditingController(
      text: existingLimit != null ? existingLimit.toStringAsFixed(0) : "",
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Set Budget"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Amount (₹)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount <= 0) {
                AppUtils.showError("Enter valid amount");
                return;
              }

              Navigator.pop(ctx);
              context.read<BudgetBloc>().add(SetBudgetLimit(amount));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
