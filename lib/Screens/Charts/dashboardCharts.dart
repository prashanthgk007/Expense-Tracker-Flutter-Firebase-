import 'package:expense_tracker_app/Helper/enum.dart';
import 'package:expense_tracker_app/Model/chartModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class DashboardCharts extends StatefulWidget {
  const DashboardCharts({super.key});

  @override
  State<DashboardCharts> createState() => _DashboardChartsState();
}

class _DashboardChartsState extends State<DashboardCharts> {
  ChartType selectedChart = ChartType.pie;
  ExpenseBasis selectedRange = ExpenseBasis.daily;

  // ------------------------
  // SAMPLE DATA
  // ------------------------
  final dailyData = [
    ExpenseCategoryData("Food", 200),
    ExpenseCategoryData("Travel", 100),
    ExpenseCategoryData("Shopping", 300),
  ];

  final weeklyData = [
    ExpenseCategoryData("Food", 1200),
    ExpenseCategoryData("Travel", 800),
    ExpenseCategoryData("Shopping", 1500),
  ];

  final monthlyData = [
    ExpenseCategoryData("Food", 4200),
    ExpenseCategoryData("Travel", 3000),
    ExpenseCategoryData("Shopping", 6000),
  ];

  // ------------------------
  // GET DATA BASED ON RANGE
  // ------------------------
  List<ExpenseCategoryData> getChartData() {
    switch (selectedRange) {
      case ExpenseBasis.daily:
        return dailyData;
      case ExpenseBasis.weekly:
        return weeklyData;
      case ExpenseBasis.monthly:
        return monthlyData;
    }
  }

  // You can also create barData(), areaData() similarly

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        // ------------------------------
        // CHART TYPE DROPDOWN
        // ------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildDropdownContainer(
                child: DropdownButton<ChartType>(
                  value: selectedChart,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: ChartType.pie, child: Text("Pie")),
                    DropdownMenuItem(value: ChartType.bar, child: Text("Bar")),
                    DropdownMenuItem(
                      value: ChartType.area,
                      child: Text("Area"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedChart = value!);
                  },
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildDropdownContainer(
                child: DropdownButton<ExpenseBasis>(
                  value: selectedRange,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ExpenseBasis.values.map((basis) {
                    return DropdownMenuItem(
                      value: basis,
                      child: Text(
                        basis.name[0].toUpperCase() + basis.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRange = value!);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ------------------------------
        // SHOW SELECTED CHART
        // ------------------------------
        if (selectedChart == ChartType.pie) _buildPieChart(getChartData()),

        if (selectedChart == ChartType.bar)
          _buildBarChart(getChartData()), // TODO: Connect range-based data

        if (selectedChart == ChartType.area)
          _buildAreaChart(getChartData()), // TODO: Connect range-based data
      ],
    );
  }

  // ------------------------------
  // CUSTOM DROPDOWN CONTAINER
  // ------------------------------
  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  // ------------------------------
  // PIE CHART
  // ------------------------------
  Widget _buildPieChart(List<ExpenseCategoryData> data) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 300,
        child: SfCircularChart(
          title: ChartTitle(text: "Expense Breakdown ($selectedRange)"),
          legend: Legend(isVisible: true),
          series: [
            PieSeries<ExpenseCategoryData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.category,
              yValueMapper: (d, _) => d.amount,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // BAR CHART (You can map range data)
  // ------------------------------
  Widget _buildBarChart(List<ExpenseCategoryData> data) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 300,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: "$selectedRange"),
          series: <CartesianSeries>[
            ColumnSeries<ExpenseCategoryData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.category,
              yValueMapper: (d, _) => d.amount,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // AREA CHART (You can map range data)
  // ------------------------------
  Widget _buildAreaChart(List<ExpenseCategoryData> data) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 300,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: "Expense Breakdown ($selectedRange)"),
          series: <CartesianSeries>[
            AreaSeries<ExpenseCategoryData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.category,
              yValueMapper: (d, _) => d.amount,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              // AREA FILL COLOR WITH OPACITY
              color: Colors.blue.withOpacity(0.4),

              // BORDER LINE
              borderColor: Colors.blue,
              borderWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
