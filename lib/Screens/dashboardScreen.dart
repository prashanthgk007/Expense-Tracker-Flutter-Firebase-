// -------------------------------------------
// HOME DASHBOARD
// -------------------------------------------
import 'package:expense_tracker_app/Helper/enum.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Screens/Charts/dashboardCharts.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

    ChartType selectedChart = ChartType.pie;

  final List<String> chartOptions = ["Pie", "Bar", "Area"];

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
            _budgetCard(),

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
            Text(title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
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
    child: Center(
      child: Text(label, style: TextStyle(fontSize: 16)),
    ),
  );
}



  Widget _budgetCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Monthly Budget: ₹10,000",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(value: 0.45),
          SizedBox(height: 10),
          Text("₹4,500 spent • 45% used"),
        ],
      ),
    );
  }
}
