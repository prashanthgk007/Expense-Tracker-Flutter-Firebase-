// -------------------------------------------
// EDIT EXPENSE
// -------------------------------------------
import 'package:flutter/material.dart';

class EditExpenseScreen extends StatelessWidget {
const EditExpenseScreen({super.key});


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Edit Expense")),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
TextField(decoration: const InputDecoration(labelText: "Title")),
TextField(decoration: const InputDecoration(labelText: "Amount")),
TextField(decoration: const InputDecoration(labelText: "Notes")),
const SizedBox(height: 20),
ElevatedButton(
onPressed: () => Navigator.pop(context),
child: const Text("Update"),
),
],
),
),
);
}
}