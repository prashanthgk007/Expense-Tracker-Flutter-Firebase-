// -------------------------------------------
// EXPENSE DETAILS
// -------------------------------------------
import 'package:flutter/material.dart';

class ExpenseDetailsScreen extends StatelessWidget {
const ExpenseDetailsScreen({super.key});


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Expense Details")),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: const [
Text("Title: Sample Expense", style: TextStyle(fontSize: 18)),
Text("Amount: ₹100", style: TextStyle(fontSize: 18)),
SizedBox(height: 20),
Text("Notes: Sample notes..."),
],
),
),
);
}
}