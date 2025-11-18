// -------------------------------------------
// SIGNUP SCREEN
// -------------------------------------------
import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Loading
          if (state is AuthLoading) {
            AppUtils.showLoading("Creating account...");
          }

          // SUCCESS
          if (state is AuthSuccess) {
            AppUtils.showSuccess("Signup Successful!");
            Navigator.pop(context); // go back to login
          }

          // FAILURE
          if (state is AuthFailure) {
            AppUtils.showError(state.error);
          }
        },

        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final password = passCtrl.text.trim();

                    // BASIC VALIDATION
                    if (email.isEmpty || password.isEmpty) {
                      EasyLoading.showError("Email & Password required");
                      return;
                    }

                    // send event to BLoC
                    context.read<AuthBloc>().add(
                      AuthSignupEvent(name, email, password),
                    );
                  },
                  child: const Text("Signup"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
