// -------------------------------------------
// FORGOT PASSWORD
// -------------------------------------------
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
const ForgotPasswordScreen({super.key});


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Reset Password")),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
TextField(decoration: const InputDecoration(labelText: "Email")),
const SizedBox(height: 20),
ElevatedButton(
onPressed: () => Navigator.pop(context),
child: const Text("Send Reset Link"),
),
],
),
),
);
}
}